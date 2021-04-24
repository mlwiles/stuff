<# 
.SYNOPSIS 
 This is used to list all of the .vmdk files associated to a VM
 
.DESCRIPTION 
This was created to be able to look at virtualized Veeam proxies and determine which VMs are using HotAdd
in the case where some of the disks are not unmounted.
 
.EXAMPLE
C:\tmp\vm-disks.ps1 -vcsa "vcsa.ibm.com" -vmname "myvm" -username "mwiles" -password "REDACTED"

.PARAMETER vcsa
   FQDN of the vcenter server appliance
.PARAMETER vmname
   vm to search for
.PARAMETER username
   username for the vcsa
.PARAMETER password
   password for the vcsa username

.LINK
   https://communities.vmware.com/t5/VMware-PowerCLI-Discussions/Get-List-of-VMs-Datastores-and-VMDK-path-per-Cluster/m-p/893492

.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2020-12-21
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Get VMWare VM Disk information
└─────────────────────────────────────────────────────────────────────────────────────────────┘
#>

param (
   [Parameter(Mandatory=$true)][string]$vcsa,
   [Parameter(Mandatory=$true)][string]$vmname,
   [Parameter(Mandatory=$true)][string]$username,
   [Parameter(Mandatory=$true)][string]$password
)
Write-Host "Connecting to VCSA: $vcsa"
$connected = Connect-VIServer -Server $vcsa -User $username -Password $password
if (-not $connected) {
  Write-Host "Could not connect to VCSA: $vcsa" 
  exit 0
}
Write-Host "Looking for VM: $vmname"
$vm = Get-VM -Server $vcsa -Name $vmname
if (-not $vm) {
  Write-Host "Could not find VM: $vmname" 
  exit 0
}

ForEach ($HardDisk in ($vm | Get-HardDisk | Sort-Object -Property Name)) {
"" | Select-Object -Property @{N="VM";E={$VM.Name}},
    @{N="Datacenter";E={$Datacenter.name}},
    @{N="Cluster";E={$Cluster.Name}},
    @{N="Hard Disk";E={$HardDisk.Name}},
    @{N="Datastore";E={$HardDisk.FileName.Split("]")[0].TrimStart("[")}},
    @{N="VMDKpath";E={$HardDisk.FileName}}
} 
