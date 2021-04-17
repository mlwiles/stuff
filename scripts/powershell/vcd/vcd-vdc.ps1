#https://communities.vmware.com/community/vmtn/automationtools/powercli/vcdpowercli
#https://code.vmware.com/docs/10197/cmdlet-reference
#https://pubs.vmware.com/vsphere-51/index.jsp?topic=%2Fcom.vmware.powercli.cmdletref.doc%2FGet-ExternalNetwork.html

try {
   . ("C:\Users\mwiles\Desktop\Get-IpRange.ps1")
}
catch {
   Write-Host "Error while loading supporting PowerShell Scripts" 
}

$vcloud = Connect-CIServer -Server "sdaldir01.vmware-solutions.cloud.ibm.com" -User "mwiles@st.dir" -Password "REDACTED"
$exNetwork = Get-ExternalNetwork -Name "dal10-w02-tenant-external" -Server $vcloud

Write-Host "exNetwork.ExtensionData.Configuration.IpScopes.IpScope.SubAllocations"
$totalSubAllocIPs = @()
$subAllocatedIps = $exNetwork.ExtensionData.Configuration.IpScopes.IpScope.SubAllocations
$counter = 0
foreach ($subAllocatedIp in $subAllocatedIps) {
   $ipRanges = $subAllocatedIp.SubAllocation[$counter].IpRanges.IpRange[0]
   
   foreach ($ipRange in $ipRanges) {
      $ips = Get-IpRange -start $ipRange.StartAddress -end $ipRange.EndAddress
      foreach ($ip in $ips) {
         Write-Host $ip
      }
   }
   $counter++
}
pause 

Write-Host "exNetwork.ExtensionData.Configuration.IpScopes.IpScope"
$totalAssignedIPs = @()
$AssignedIps = $exNetwork.ExtensionData.Configuration.IpScopes.IpScope
foreach ($AssignedIp in $AssignedIps) {
   $ips = $AssignedIp.IpAddress -split ' ' 
   foreach ($ip in $ips) {
      $totalAssignedIPs += $ip
   }
}
$totalAssignedIPs | Sort-Object 

pause

$totalAllocIPs = @()
Write-Host "exNetwork.ExtensionData.Configuration.IpScopes.IpScope.AllocatedIpAddresses"
$AllocatedIps = $exNetwork.ExtensionData.Configuration.IpScopes.IpScope.AllocatedIpAddresses
foreach ($AllocatedIp in $AllocatedIps) {
   $ips = $AllocatedIp.IpAddress -split ' ' 
   foreach ($ip in $ips) {
      $totalAllocIPs += $ip
   }
}
$totalAllocIPs | Sort-Object 

#Write-Host $exNetwork.StaticIPPool
#$count = $exNetwork.StaticIPPool.Count
#Write-Host "Count="$count
#for ($i=0; $i -lt $count; $i++) {
#   Write-Host $exNetwork.StaticIPPool.Item($i)
#}

pause

$pvdcs = Get-ProviderVdc -Server $vcloud

foreach ($pvdc in $pvdcs) {
   Write-Host ";"
   Write-Host ";Name=" $pvdc.Name
   $rounded = [math]::round($pvdc.CpuAllocatedGHz, 2)
   Write-Host ";CpuAllocatedGHz=" $rounded
   $rounded = [math]::round($pvdc.CpuOverheadGHz, 2)
   Write-Host ";CpuOverheadGHz=" $rounded
   $rounded = [math]::round($pvdc.CpuTotalGHz, 2)
   Write-Host ";CpuTotalGHz=" $rounded
   $rounded = [math]::round($pvdc.CpuUsedGHz, 2)
   Write-Host ";CpuUsedGHz=" $rounded
   Write-Host ";Description=" $pvdc.Description
   Write-Host ";Enabled=" $pvdc.Enabled
   #Write-Host ";ExtensionData.=" $pvdc.ExtensionData.
   Write-Host ";HighestSupportedHardwareVersion=" $pvdc.HighestSupportedHardwareVersion
   Write-Host ";Href=" $pvdc.Href
   Write-Host ";Id=" $pvdc.Id
   $rounded = [math]::round($pvdc.MemoryAllocatedGB, 2)
   Write-Host ";MemoryAllocatedGB=" $rounded
   $rounded = [math]::round($pvdc.MemoryOverheadGB, 2)
   Write-Host ";MemoryOverheadGB=" $rounded
   $rounded = [math]::round($pvdc.MemoryTotalGB, 2)
   Write-Host ";MemoryTotalGB=" $rounded
   $rounded = [math]::round($pvdc.MemoryUsedGB, 2)
   Write-Host ";MemoryUsedGB=" $rounded
   Write-Host ";Status=" $pvdc.Status
   $rounded = [math]::round($pvdc.StorageAllocatedGB, 2)
   Write-Host ";StorageAllocatedGB=" $rounded
   $rounded = [math]::round($pvdc.StorageOverheadGB, 2)
   Write-Host ";StorageOverheadGB=" $rounded
   Write-Host ";StorageProfiles.Count=" $pvdc.StorageProfiles.Count
   $rounded = [math]::round($pvdc.StorageTotalGB, 2)
   Write-Host ";StorageTotalGB=" $rounded
   $rounded = [math]::round($pvdc.StorageUsedGB, 2)
   Write-Host ";StorageUsedGB=" $rounded
   Write-Host ";Uid=" $pvdc.Uid
}

pause
$orgs = Get-Org -Server $vcloud #| Sort-Object -Property Name

foreach ($org in $orgs) {
   "org = " + $org.FullName #org.name
   $vdcs = Get-OrgVdc -Org $org
   foreach ($vdc in $vdcs) {
      Write-Host ";Name=" $vdc.Name 
      Write-Host ";CpuAllocationGhz=" $vdc.CpuAllocationGhz 
      Write-Host ";CpuGuaranteedPercent=" $vdc.CpuGuaranteedPercent 
      Write-Host ";CpuLimitGhz=" $vdc.CpuLimitGhz
      Write-Host ";CpuOverheadGhz=" $vdc.CpuOverheadGhz
      Write-Host ";CpuUsedGhz=" $vdc.CpuUsedGhz
      Write-Host ";Description=" $vdc.Description
      Write-Host ";Enabled=" $vdc.Enabled
      #Write-Host ";ExtensionData.ComputeCapacity=" $vdc.ExtensionData.
      Write-Host ";Href=" $vdc.Href
      Write-Host ";Id=" $vdc.Id
      Write-Host ";MemoryAllocationGB=" $vdc.MemoryAllocationGB
      Write-Host ";MemoryGuaranteedPercent=" $vdc.MemoryGuaranteedPercent
      Write-Host ";MemoryLimitGB=" $vdc.MemoryLimitGB
      Write-Host ";MemoryOverheadGB=" $vdc.MemoryOverheadGB
      Write-Host ";MemoryUsedGB=" $vdc.MemoryUsedGB
      Write-Host ";Name=" $vdc.Name
      Write-Host ";NetworkMaxCount=" $vdc.NetworkMaxCount
      Write-Host ";NetworkPool.Name=" $vdc.NetworkPool
      Write-Host ";ProviderVdc.Name=" $vdc.ProviderVdc.Name
      Write-Host ";Status=" $vdc.Status
      Write-Host ";StorageAllocationGB=" $vdc.StorageAllocationGB
      Write-Host ";StorageLimitGB=" $vdc.StorageLimitGB
      Write-Host ";StorageOverheadGB=" $vdc.StorageOverheadGB
      Write-Host ";StorageProfiles=" $vdc.StorageProfiles
      Write-Host ";StorageUsedGB=" $vdc.StorageUsedGB
      Write-Host ";ThinProvisioned=" $vdc.ThinProvisioned
      Write-Host ";Uid=" $vdc.Uid
      Write-Host ";UseFastProvisioning=" $vdc.UseFastProvisioning
      Write-Host ";VAppCount=" $vdc.VAppCount
      Write-Host ";VMCpuCoreMHz=" $vdc.VMCpuCoreMHz
      Write-Host ";VMMaxCount=" $vdc.VMMaxCount
   }
}

Disconnect-CIServer $vcloud -Force -Confirm:$false