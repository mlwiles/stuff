 # =====================
# Author: Mike Wiles
# Date: 2020/08/22
# Purpose: Get DVPG DVS Port Settings (MacLearning, MacManagement, ForgedTransmits) - Prep for Hands On Lab config
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

# Get DVSwitch:
# ---------------------------
if ($no_errors){
   Write-Host "Getting DVSwitch for $dvsname"
   $dvs = Get-VDSwitch -Name $dvsname -ErrorAction SilentlyContinue

   if($dvs) {
      $securityPolicy = $dvs.ExtensionData.Config.DefaultPortConfig.SecurityPolicy
      $macMgmtPolicy = $dvs.ExtensionData.Config.DefaultPortConfig.MacManagementPolicy
      
      $securityPolicyResults = [pscustomobject] @{
          MacLearning = $macMgmtPolicy.MacLearningPolicy.Enabled;
          NewAllowPromiscuous = $macMgmtPolicy.AllowPromiscuous;
          NewForgedTransmits = $macMgmtPolicy.ForgedTransmits;
          NewMacChanges = $macMgmtPolicy.MacChanges;
          Limit = $macMgmtPolicy.MacLearningPolicy.Limit
          LimitPolicy = $macMgmtPolicy.MacLearningPolicy.limitPolicy
          LegacyAllowPromiscuous = $securityPolicy.AllowPromiscuous.Value;
          LegacyForgedTransmits = $securityPolicy.ForgedTransmits.Value;
          LegacyMacChanges = $securityPolicy.MacChanges.Value;
      }
      $securityPolicyResults
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
 
