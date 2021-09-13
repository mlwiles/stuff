# =====================
# Author: Mike Wiles
# Date: 2020/08/22
# Purpose: Set DVS Port Settings (MacLearning, MacManagement, ForgedTransmits) - Prep for Hands On Lab config
# setting this property on the portgroup only
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
$dvpgname = Read-Host "Enter the DV Port Group - Example: vxw-dvs-127-virtualwire-name" 

# Make Connection:
# ----------------
Write-Host "Connecting to $vcsa_fqdn ..."
$vcsa = Connect-VIServer $vcsa_fqdn

# Set VDPortgroup:
# ---------------------------
if ($no_errors){
    Write-Host "Getting VDPortgroup for $dvpgname"
    $dvpg = Get-VDPortgroup -Name $dvpgname -ErrorAction SilentlyContinue
    
    if($dvpg -and [version]$switchVersion -ge [version]$minSwitchVersion) {
        Write-Host "Checking VDSwitch Version"
        $switchVersion = ($dvpg | Get-VDSwitch).Version
        Write-Host "Retrieving current SecurityPolicy"
        $originalSecurityPolicy = $dvpg.ExtensionData.Config.DefaultPortConfig.SecurityPolicy

        Write-Host "Creating new Policy objects"              
        $spec = New-Object VMware.Vim.DVPortgroupConfigSpec
        $dvPortSetting = New-Object VMware.Vim.VMwareDVSPortSetting
        $macMmgtSetting = New-Object VMware.Vim.DVSMacManagementPolicy
        $macLearnSetting = New-Object VMware.Vim.DVSMacLearningPolicy
        $macMmgtSetting.MacLearningPolicy = $macLearnSetting
        $dvPortSetting.MacManagementPolicy = $macMmgtSetting
        $spec.DefaultPortConfig = $dvPortSetting
        $spec.ConfigVersion = $dvpg.ExtensionData.Config.ConfigVersion

        $macMmgtSetting.AllowPromiscuous = $false
        $macMmgtSetting.ForgedTransmits = $true
        $macMmgtSetting.MacChanges = $false
        $macLearnSetting.Enabled = $true
        $macLearnSetting.AllowUnicastFlooding = $true
        $macLearnSetting.Limit = 4000
        $macLearnSetting.LimitPolicy = "DROP"

        Write-Host "Reconfiguring VDPortgroup"
        $task = $dvpg.ExtensionData.ReconfigureDVPortgroup_Task($spec)
        $task1 = Get-Task -Id ("Task-$($task.value)")
        $task1 | Wait-Task | Out-Null
        Write-Host "Reconfig completed"
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
 
