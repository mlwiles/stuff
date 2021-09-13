# =====================
# Author: Mike Wiles
# Date: 2021/08/26
# Purpose: Get DVS PortGroups for a Given DVSwitch
#
# =====================

# Fixed variables:
# ----------------
$no_errors = $True
$minSwitchVersion = "6.6.0"

# Input variables:
# ----------------
$vcsa_fqdn = Read-Host "Enter the VCSA FQDN - Example: vcenter-name" 
$dvsname = Read-Host "Enter the DVSwitch to query VDPortgroup - Example: sdalha1w04-bcr01a.dal13-private" 

# Make Connection:
# ----------------
Write-Host "Connecting to $vcsa_fqdn ..."
$vcsa = Connect-VIServer $vcsa_fqdn

# Get VDPortgroups:
# ---------------------------
if ($no_errors) {
    Write-Host "Getting VDPortgroups for $dvsname"
    $dvpgs = Get-VDPortgroup -VDSwitch $dvsname -ErrorAction SilentlyContinue

    foreach ($dvpg in $dvpgs) {
    
        $dvpg.Name
        $switchVersion = ($dvpg | Get-VDSwitch).Version
        if($dvpg -and [version]$switchVersion -ge [version]$minSwitchVersion) {
        }
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
 
