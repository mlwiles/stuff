 # https://stackoverflow.com/questions/36456104/invoke-restmethod-ignore-self-signed-certs

 if (-not("dummy" -as [type])) {
    add-type -TypeDefinition @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public static class Dummy {
    public static bool ReturnTrue(object sender,
        X509Certificate certificate,
        X509Chain chain,
        SslPolicyErrors sslPolicyErrors) { return true; }
    public static RemoteCertificateValidationCallback GetDelegate() {
        return new RemoteCertificateValidationCallback(Dummy.ReturnTrue);
    }
}
"@
}
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = [dummy]::GetDelegate()

$username = "mwiles@domain"
$password = "REDACTED"
$vcdserver = "daldir01.vmware-solutions.cloud.ibm.com"
$vcsaName = "vcenter-name"

$vdcCounter = 0 
$vdcNetworkCounter = 0
$vdcNetRoutedCounter = 0
$vdcNetDistributedCounter = 0
$disableDLR = $true

# connect to vcsa and scope down to the datacenter, cluster, recourcepool ...
$vcsa = Connect-VIServer -Server $vcsaName -User $username -Password $password

# create a connection to the NSX manager
$nsxManager = Connect-NsxServer -vCenterServer $vcsa -User $username -Password $password
# set the default
$DefaultNsxConnection = $nsxManager
# get all the ESGs
$nsxESGs = Get-NsxEdge

$vcloud = Connect-CIServer -Server $vcdserver -User $username -Password $password

#authenticate against the vcd server for API request to disable distributed routing
$system = $username + "@system"
$credPair = "$($system):$($password)"
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))

$url = "https://" + $vcdserver + "/api/sessions"
$url
$headers = @{
    'Authorization' = "Basic $base64AuthInfo"
    'Accept' = "application/*+json;version=35.2"
}
$response = Invoke-WebRequest -Method POST -Uri $url -Headers $headers

$vdcs = Get-OrgVdc -Server $vcloud
foreach ($vdc in $vdcs) {
   Write-Host "VDC: " $vdc.Name
   $vdcCounter++
   $disableDLR = $true
   $orgVdcNetworks = Get-OrgVdcNetwork -OrgVdc $vdc
   foreach ($orgVdcNetwork in $orgVdcNetworks) {
      $vdcNetworkCounter++
      if ($orgVdcNetworks.NetworkType -eq "Routed") {
         $vdcNetRoutedCounter++
         if ($orgVdcNetwork.ExtensionData.Configuration.DistributedInterface) {
            $vdcNetDistributedCounter++
            Write-Host "----" $vdc.Name ":" $orgVdcNetwork.Name ":" $orgVdcNetwork.NetworkType ": DISTRIBUTED"
            $disableDLR = $false
         } else {
            Write-Host "----" $vdc.Name ":" $orgVdcNetwork.Name ":" $orgVdcNetwork.NetworkType
         }
      } else {
         Write-Host "----" $vdc.Name ":" $orgVdcNetwork.Name ":" $orgVdcNetwork.NetworkType
      }
   }
   if ($disableDLR) {
      $esg = Get-EdgeGateway -OrgVdc $vdc
      $esgName = $esg.Name
      Write-Host "--Disable Distributed Routing: ESGID: " $esgName
 
      if ($esgName) {
         foreach ($nsxESG in $nsxESGs) {
            $nsxName = $nsxESG.name
            if ($nsxName -match $esgName) {                        
            
               $url = $esg.Href + "/action/disableDistributedRouting"
               Write-Host $url
               $token = $response.Headers.'x-vcloud-authorization'
               $headers = @{
                   'x-vcloud-authorization' = "$token"
                   'Accept' = "application/*+json;version=35.2"
               } 

               try {     
                   $vcdpayload = Invoke-RestMethod -Method POST -Uri $url -Headers $headers -ContentType "application/*+json"
               }
               catch {
                   $errorMessage = $_.Exception.Message
                   $failedItem = $_.Exception.ItemName
                   Write-Error "$errorMessage $failedItem"
               }
            }
         }
      }
   }
}
 

# clean up
Disconnect-NsxServer -Server $nsxManager -Confirm:$false 
Disconnect-VIServer -Server $vcsa -Confirm:$false 
Disconnect-CIServer -Server $vcloud -Confirm:$false 

Write-Host "========================================"
Write-Host "vDC Count = $vdcCounter"
Write-Host "Network Count = $vdcNetworkCounter"
Write-Host "Network(Routed) Count = $vdcNetRoutedCounter"
Write-Host "Network(Distributed) Count = $vdcNetDistributedCounter"

 
