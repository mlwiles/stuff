<# 
.SYNOPSIS 
 Identify new DLRs that need to be HA'd and relocated
 
.DESCRIPTION 
 Part of the process of creating a Datacenter Group is to enable egress point.  Once the egress point is enabled,
 a Distributed Logical Router is deployed.  Out of the box HA is disabled.
 Our use case is to enable HA.  Once HA is enabled we want to relocate the HA Index one machine to the other side
 of the stretch network so that in case of failover, its reachable.
 
.EXAMPLE
C:\tmp\NSX-DLR-HA-Relocate.ps1 -username "mwiles@st.dir" -password "REDACTED"
 
.PARAMETER username
   username for the vcsa
.PARAMETER password
   password for the vcsa username 

.LINK
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2021-04-24
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Identify new DLRs that need to be HA'd and relocated
└─────────────────────────────────────────────────────────────────────────────────────────────┘
#>
param (
   [Parameter(Mandatory=$true)][string]$username,
   [Parameter(Mandatory=$true)][string]$password
)

# where to look for new DLRs that need to be HA'd
$vcsaName = "vcenter-sDal10W02.sDal10W02.st.dir"
$sourceDCName = "datacenter-dal10"
$sourceClusterName = "cluster1"
$sourceResourcePoolName = "dal10-dir02-w02-DLRS"

# where to move the DLR to - ResourcePool, Host, Datastore
$targetDatastoreName = "workload_share_tC2RA_4"
$targetDatastoreId = "datastore-4511"
#$targetHostName = "host013.sdal10w02.st.dir"
#$targetHostId = "host-6447"  
$targetHostName = "" #leave blank as this is not required but we want to remove what is there
$targetHostId = ""  #leave blank as this is not required but we want to remove what is there
$targetResourcePoolName = "dal10-dir02-w02-work01-alloc01"
$targetResourcePoolId = "resgroup-55760"

# connect to vcsa and scope down to the datacenter, cluster, recourcepool ...
$vcsa = Connect-VIServer -Server $vcsaName -User $username -Password $password
$sourceDC = Get-Datacenter -Server $vcsa -Name $sourceDCName
$sourceCluster = Get-Cluster -Server $vcsa -Location $sourceDC -Name $sourceClusterName
$sourceResourcePool = Get-ResourcePool -Server $vcsa -Location $sourceCluster -Name $sourceResourcePoolName
# get the current vms in the resource pool
$sourceDLRVMs = Get-VM -Server $vcsa -Location $sourceResourcePool

# create a connection to the NSX manager
$nsxManager = Connect-NsxServer -vCenterServer $vcsa -User $username -Password $password
# set the default
$DefaultNsxConnection = $nsxManager

# get all the DLRs on the vcenter, this is more efficent to just traverse the list 
# then getting a single DLR by name
$nsxDLRs = Get-NsxLogicalRouter

foreach ($sourceDLRVM in $sourceDLRVMs) 
{
   # remove the trailing "-0" or "-1"
   $sourceDLRVMName = $sourceDLRVM.Name
   Write-Output "Checking DLR $sourceDLRVMName"
   $splitstring = $sourceDLRVMName.Split("-")
   $nsxDLRName = $splitstring[0]

   # find the DLR in the collection
   $nsxDLR = $nsxDLRs | Where-Object { $_.name –contains $nsxDLRName }
   
   # if the DLR is not HA enabled
   if ("false" -eq $nsxDLR.features.highAvailability.enabled) {
      Write-Output "   Enable HA for DLR $sourceDLRVMName"
      # enable HA and save it back to NSX
      $nsxDLR.features.highAvailability.enabled = "true"
      $nsxDLR | Set-NsxLogicalRouter -Confirm:$false

      # get a new version of the recently saved DLR
      $nsxDLR = Get-NsxLogicalRouter | Where-Object { $_.name –contains $nsxDLRName }
      $appliances = $nsxDLR.appliances.appliance
      # get the appliances for the DLR
      foreach ($appliance in $appliances) {
         
         # this is the new appliance that was just deployed, now move it to target location and save it back to NSX
         if ($appliance.highAvailabilityIndex -eq 1) {
            Write-Output "   Relocate appliance for DLR $sourceDLRVMName"
            $appliance.resourcePoolName = $targetResourcePoolName
            $appliance.resourcePoolId = $targetResourcePoolId
            $appliance.datastoreName = $targetDatastoreName
            $appliance.datastoreId = $targetDatastoreId
            $appliance.hostName = $targetHostName
            $appliance.hostId = $targetHostId
            $nsxDLR | Set-NsxLogicalRouter -Confirm:$false
         }
      } 
   } else {
      Write-Output "   HA previously enabled for DLR $sourceDLRVMName"
   }
}

# clean up
Disconnect-NsxServer -Server $nsxManager -Confirm:$false 
Disconnect-VIServer -Server $vcsa -Confirm:$false 