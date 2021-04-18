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

Function Convert-UserFlag {
  Param ($Flag)
  $List = New-Object System.Collections.ArrayList
  Switch ($Flag) {
    ($Flag -BOR 0x0001)     {[void]$List.Add('SCRIPT')}
    ($Flag -BOR 0x0002)     {[void]$List.Add('ACCOUNTDISABLE')}
    ($Flag -BOR 0x0008)     {[void]$List.Add('HOMEDIR_REQUIRED')}
    ($Flag -BOR 0x0010)     {[void]$List.Add('LOCKOUT')}
    ($Flag -BOR 0x0020)     {[void]$List.Add('PASSWD_NOTREQD')}
    ($Flag -BOR 0x0040)     {[void]$List.Add('PASSWD_CANT_CHANGE')}
    ($Flag -BOR 0x0080)     {[void]$List.Add('ENCRYPTED_TEXT_PWD_ALLOWED')}
    ($Flag -BOR 0x0100)     {[void]$List.Add('TEMP_DUPLICATE_ACCOUNT')}
    ($Flag -BOR 0x0200)     {[void]$List.Add('NORMAL_ACCOUNT')}
    ($Flag -BOR 0x0800)     {[void]$List.Add('INTERDOMAIN_TRUST_ACCOUNT')}
    ($Flag -BOR 0x1000)     {[void]$List.Add('WORKSTATION_TRUST_ACCOUNT')}
    ($Flag -BOR 0x2000)     {[void]$List.Add('SERVER_TRUST_ACCOUNT')}
    ($Flag -BOR 0x10000)    {[void]$List.Add('DONT_EXPIRE_PASSWORD')}
    ($Flag -BOR 0x20000)    {[void]$List.Add('MNS_LOGON_ACCOUNT')}
    ($Flag -BOR 0x40000)    {[void]$List.Add('SMARTCARD_REQUIRED')}
    ($Flag -BOR 0x80000)    {[void]$List.Add('TRUSTED_FOR_DELEGATION')}
    ($Flag -BOR 0x100000)   {[void]$List.Add('NOT_DELEGATED')}
    ($Flag -BOR 0x200000)   {[void]$List.Add('USE_DES_KEY_ONLY')}
    ($Flag -BOR 0x400000)   {[void]$List.Add('DONT_REQ_PREAUTH')}
    ($Flag -BOR 0x800000)   {[void]$List.Add('PASSWORD_EXPIRED')}
    ($Flag -BOR 0x1000000)  {[void]$List.Add('TRUSTED_TO_AUTH_FOR_DELEGATION')}
    ($Flag -BOR 0x04000000) {[void]$List.Add('PARTIAL_SECRETS_ACCOUNT')}
  }  
  $List -join ', '
}

Function IsPasswordExpired {
  Param ($UserFlag)
  $Expired = $false
  Switch ($UserFlag) {
    ($UserFlag -BOR 0x800000) {$Expired = $true}
  }
  return $Expired
}

Function IsPasswordDontExpired {
  Param ($UserFlag)
  $DontExpire = $false
  Switch ($UserFlag) {
    ($UserFlag -BOR 0x10000) {$DontExpire = $true}
  }
  return $DontExpire
}

$DEBUG = 0
$LOGFILE="/var/log/wfss.chagecheck.log"
$INFODAYS=15
$WARNINGDAYS=5
$EXPIREDDAYS=0

$expUsers = @()

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
   $name = $_.Name
   $UserFlags = Convert-UserFlag $_.UserFlags[0]
   if ($DEBUG) { Write-Host "UserFlags:" $UserFlags }

   $PwdAge = [math]::Round($_.PasswordAge[0]/86400)
   if (IsPasswordDontExpired $_.UserFlags[0]) {
      Write-Host "NORMAL:Password for $name does not expire"
   } else {
      # Convert from seconds to days.
      $AgeDays = $_.PasswordAge.psbase.Value / 86400
      $MaxAge = $_.MaxPasswordAge.psbase.Value / 86400
      if ($DEBUG) { Write-Host  "Name:" $name "AgeDays:" $AgeDays "MaxAge:" $MaxAge }

      $ExpireDays = [int]($MaxAge - $AgeDays)

      if ( $ExpireDays -le 0 ) {
         $expUsers += "EXPIRED:Password for $Name is expired $ExpireDays days"
      } elseif ( $ExpireDays -le $WARNINGDAYS ) {
         Write-Host "WARNING:Password for $Name will expire in $ExpireDays days"
      } elseif ( $ExpireDays -le $INFODAYS ) {
         Write-Host "INFO:Password for $Name will expire in $ExpireDays days"
      } else {
         Write-Host "NORMAL:Password for $Name will expire in $ExpireDays days"
      }
   }
}

Foreach ($expUser in $expUsers) {
	Write-Host $expUser
}



