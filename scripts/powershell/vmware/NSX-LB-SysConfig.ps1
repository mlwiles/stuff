<# 
.SYNOPSIS 
 Gets/Sets header and buffer sizes
 
.DESCRIPTION 

.EXAMPLE
C:\tmp\NSX-LB-SysConfig.ps1
 
.PARAMETER username
   username for the vcsa
.PARAMETER password
   password for the vcsa username 

.LINK
https://stackoverflow.com/questions/40184128/powershell-invoke-restmethod-error-when-passing-xml-body
https://kb.vmware.com/s/article/52553
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2021-05-23
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Gets/Sets header and buffer sizes
└─────────────────────────────────────────────────────────────────────────────────────────────┘
#>
#param (
#   [Parameter(Mandatory=$true)][string]$username,
#   [Parameter(Mandatory=$true)][string]$password
#)
 
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
$hostname = Read-Host "NSX Manager FQDN (ex: NsxManager.intranet.com)" 
$username = Read-Host "NSX Manager admin ID (ex: adminuser)"
$password = Read-Host "NSX Manager password (ex: pwd123!@#)"
$edgeid = Read-Host "NSX EdgeID (ex: edge-123)"
$GET = Read-Host "Get or Set (Get=1, Set=0)"
$DEBUG = 0
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
$headers = @{
    'Authorization' = "Basic $base64AuthInfo"
} 
$body = @{}
$url = "https://$hostname/api/4.0/edges/$edgeid/systemcontrol/config"
if ($DEBUG) {
    $url
    $headers.Keys
    $headers.Values
}
if ($GET) {
    $method = "GET"
} else {
    $method = "PUT"
    $body = @"
<systemControl>
<property>lb.global.tune.http.maxhdr=1024</property>
<property>lb.global.tune.bufsize=65536</property>
</systemControl>
"@
}
try {     
    $payload = Invoke-RestMethod -Method $method -Uri $url -Body $body -Headers $headers -ContentType "application/xml"
}
catch {
    $errorMessage = $_.Exception.Message
    $failedItem = $_.Exception.ItemName
    Throw "$errorMessage $failedItem"
}
Write-Host ""
if ($GET) {
    Write-Host "Values retrieved:"
    $payload.systemControl.property
} else {
    Write-Host "Values set:"
    $body
} 