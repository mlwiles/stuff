<# 
.SYNOPSIS 
 
 
.DESCRIPTION 
 
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : 
└─────────────────────────────────────────────────────────────────────────────────────────────┘
 
#>

$username = "WINDOWSUSER"
$separator = "_"
$suffix = "PRE1"

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
  $name = $_.Name
  if ($name -match $username) {
     #Temporarily change security policy
     secedit /export /cfg c:\secpol.cfg
     (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
     secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY

     #create the password and update
     Write-Host "found user $username"
     #mangle the userid to create the password
     $uidTOpwd = [System.StringSplitOptions]::RemoveEmptyEntries
     $front, $back = $username.Split($separator,2, $uidTOpwd)
     Write-Host "front: $front -- back: $back" 
     net user $username $back$separator$front$suffix 

     #remove "password never expires

     #set password change on next login
     
     #Reset the security policy back
     secedit /export /cfg c:\secpol.cfg
     (gc C:\secpol.cfg).replace("PasswordComplexity = 0", "PasswordComplexity = 1") | Out-File C:\secpol.cfg
     secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
     
     #Remove the security policy exported file
     rm -force c:\secpol.cfg -confirm:$false
  } 
}

