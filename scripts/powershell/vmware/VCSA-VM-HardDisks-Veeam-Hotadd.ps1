<# 
.SYNOPSIS 
 Display the attached .vmdk files on the Veeam proxy.
 
.DESCRIPTION  
 There are times when the Veeam Cloud Connect / Availability Service leave behind a VM .vmdk file when performing
 hotadd of the VM drive.  This can cause issues in the future jobs.  So this script is the first step in displaying the 
 attached drives to the Veeam proxies.
 
.EXAMPLE
 
.PARAMETER  

.LINK
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2021-04-23
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Display the attached .vmdk files on the Veeam proxy
└─────────────────────────────────────────────────────────────────────────────────────────────┘
#>

param (
   [Parameter(Mandatory=$true)][string]$vcsa,
   [Parameter(Mandatory=$true)][string]$vmname,
   [Parameter(Mandatory=$true)][string]$username,
   [Parameter(Mandatory=$true)][string]$password
)
#$vcsa =  "fraha1w02-vc.pr.dir"
$proxies = ""


#Veeam Cloud Connect
$proxies = @('fra04vcccupr01','fra04vcccupr02','fra04vcccupr03','fra04vcccupr04') 
         # --> these are not running in workload yet --- 'fra02vcccupr01','fra05vcccupr01','fra05vcccupr02')

         #Veeam Availablity Service - Backup
#$proxies = @('fra04veecupr01') 
# --> these are not running in workload yet --- 'fra02veecupr01','fra05veecupr01')

$vcsa = Connect-VIServer -Server $vcsa -User $username -Password $password

foreach ($proxy in $proxies)
{ 
   Get-VM -Server $vcsa -Name $proxy | get-harddisk | select Parent,Filename
}

Disconnect-VIServer -Server $vcsa -confirm:$false 