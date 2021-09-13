# =====================
# Author: Mike Wiles
# Date: 2020/08/22
# Purpose: Set DVPG DVS Port Settings (MacLearning, MacManagement, ForgedTransmits) - Prep for Hands On Lab config
# setting this property on the switch will allow new portgroups to inherit these properties
#
# https://fojta.wordpress.com/2020/07/06/enable-mac-learning-as-default-on-vsphere-distributed-switch/
#
# =====================

# Fixed variables:
# ----------------
$no_errors = $True
$minSwitchVersion = "6.6.0"

# Input variables:
# ----------------
$vcsa_fqdn = Read-Host "Enter the VCSA FQDN - Example: vcenter-name" 
$dvsname = Read-Host "Enter the DV Switch - Example: w02-dal-work-private" 

# Make Connection:
# ----------------
Write-Host "Connecting to $vcsa_fqdn ..."
$vcsa = Connect-VIServer $vcsa_fqdn

# Set DVSwitch:
# ---------------------------
if ($no_errors){
   Write-Host "Getting DVSwitch for $dvsname"
   $dvs = Get-VDSwitch -Name $dvsname -ErrorAction SilentlyContinue

   if($dvs) {
    Write-Host "Retrieving current SecurityPolicy"
    $originalSecurityPolicy = $dvs.ExtensionData.Config.DefaultPortConfig.SecurityPolicy
     
    Write-Host "Creating new Policy objects"              
    $spec = New-Object VMware.Vim.DVSConfigSpec
    $dvPortSetting = New-Object VMware.Vim.VMwareDVSPortSetting
    $macMmgtSetting = New-Object VMware.Vim.DVSMacManagementPolicy
    $macLearnSetting = New-Object VMware.Vim.DVSMacLearningPolicy
    $securityPolicy = New-Object VMware.Vim.DVSSecurityPolicy
    $macMmgtSetting.MacLearningPolicy = $macLearnSetting
    $dvPortSetting.MacManagementPolicy = $macMmgtSetting
    $dvPortSetting.SecurityPolicy = $securityPolicy
    $spec.DefaultPortConfig = $dvPortSetting
    $spec.ConfigVersion = $dvs.ExtensionData.Config.ConfigVersion

    $macMmgtSetting.AllowPromiscuous = $false
    $macMmgtSetting.ForgedTransmits = $true
    $macMmgtSetting.MacChanges = $false
    $macLearnSetting.Enabled = $true
    $macLearnSetting.AllowUnicastFlooding = $true
    $macLearnSetting.Limit = 4000
    $macLearnSetting.LimitPolicy = "DROP"

    $securityPolicy.AllowPromiscuous.Value;
    $securityPolicy.ForgedTransmits = New-Object VMware.Vim.BoolPolicy
    $securityPolicy.ForgedTransmits.Inherited = $false
    $securityPolicy.ForgedTransmits.value = $true
 
    Write-Host "Reconfiguring DVSwitch"
    $task = $dvs.ExtensionData.ReconfigureDvs_Task($spec)
    $task1 = Get-Task -Id ("Task-$($task.value)")
    $task1 | Wait-Task 
   }
}

# End:
# ----
Write-Host "Disconnecting from $vcsa_fqdn ..."
Disconnect-VIServer -Confirm:$False
if ($no_errors){
    Write-Host "-----"
    Write-Host "Done."
    Exit 0
} else {
    Exit 1
}
 
