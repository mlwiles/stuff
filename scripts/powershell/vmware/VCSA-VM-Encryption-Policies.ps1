<# 
.SYNOPSIS 
 List encryption policies for VMs
 
.DESCRIPTION 
 
.EXAMPLE
 
.PARAMETER  

.LINK
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2021-01-22
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : List encryption policies for VMs
└─────────────────────────────────────────────────────────────────────────────────────────────┘
#>

$connectedVCSA = Connect-VIServer -Server "vcenter-sdalha1m01.st.dir" -User "ID" -Password "PWD"
$datacenterList=Get-Datacenter -Server $connectedVCSA | Sort-Object -Property Name
foreach ($datacenter in $datacenterList)
{
   $dcFolders = (Get-Folder -Server $vcsa -Location $datacenter.Name -NoRecursion -Type HostAndCluster) | Sort-Object -Property Name
   foreach ($dcFolder in $dcFolders)
   {
      $clusters = (Get-Cluster -Server $vcsa -Location $dcFolder -NoRecursion) | Sort-Object -Property Name 
      $clusterCount += $clusters.Count
      foreach ($cluster in $clusters)
      {
         $vmhosts = (Get-VMHost -Server $vcsa -Location $cluster -NoRecursion) | Sort-Object -Property Name
         foreach ($vmhost in $vmhosts)
         {
            $vms = (Get-VM -Server $vcsa -Location $vmhost) | Sort-Object -Property Name
            foreach ($vm in $vms)
            {
               $sbpm = Get-SpbmEntityConfiguration -VM $vm
               $sbpm
            }
         }
      }
   }
}
Disconnect-VIServer -Server $connectedVCSA -confirm:$false 