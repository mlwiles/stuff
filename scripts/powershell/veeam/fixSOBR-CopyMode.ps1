Add-PSSnapin veeampssnapin
Connect-VBRServer -Server "HOSTNAME"

$sobrs = Get-VBRBackupRepository -ScaleOut
$countertotal = 0
$counter = 0

$proxy = Get-VBRServer -Name "HOSTNAME"
foreach ($sobr in $sobrs) {
   if ($sobr.CapacityTierCopyPolicyEnabled -ne $true) {
      $sobr.Name
      if ($sobr.Name -eq "SOBR_NAME") {
         continue
      }
      $counter++
      #Set-VBRScaleOutBackupRepository -Repository $sobr -Extent $sobr.Extent -PolicyType DataLocality -OperationalRestorePeriod 0 -EnableCapacityTier -EnableCapacityTierCopyPolicy
      #$cosname = "cos_" + $sobr.Name
      #$cos = Get-VBRObjectStorageRepository -Name $cosname
      #$cos
      #Set-VBRAmazonS3CompatibleRepository -Repository $cos -UseGatewayServer -GatewayServer $proxy
    
   }
   $countertotal++
}

Write-Host "Total without CopyMode = " $counter
Write-Host "Total = " $countertotal

Disconnect-VBRServer