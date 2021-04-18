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

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"

#$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
#    $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
#    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
#}

#$Users = $adsi.Children  | where {$_.SchemaClassName  -eq 'user'} | ForEach {
#  #Write-Host "Name:" $_.Name         
#  $Username = "powershell"
#  if ($_.Name -eq $Username) {
#    $_ | Select * 
#  }
#}

$env:Computername | Get-LocalUser 
Function Get-LocalUser  {
  [Cmdletbinding()]
  Param([Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [String[]]$Computername =  $Env:Computername)

  Begin {
    Function  Convert-UserFlag {
      Param  ($UserFlag)
      $List  = New-Object  System.Collections.ArrayList
      Switch  ($UserFlag) {
        ($UserFlag  -BOR 0x0001)  {[void]$List.Add('SCRIPT')}
        ($UserFlag  -BOR 0x0002)  {[void]$List.Add('ACCOUNTDISABLE')}
        ($UserFlag  -BOR 0x0008)  {[void]$List.Add('HOMEDIR_REQUIRED')}
        ($UserFlag  -BOR 0x0010)  {[void]$List.Add('LOCKOUT')}
        ($UserFlag  -BOR 0x0020)  {[void]$List.Add('PASSWD_NOTREQD')}
        ($UserFlag  -BOR 0x0040)  {[void]$List.Add('PASSWD_CANT_CHANGE')}
        ($UserFlag  -BOR 0x0080)  {[void]$List.Add('ENCRYPTED_TEXT_PWD_ALLOWED')}
        ($UserFlag  -BOR 0x0100)  {[void]$List.Add('TEMP_DUPLICATE_ACCOUNT')}
        ($UserFlag  -BOR 0x0200)  {[void]$List.Add('NORMAL_ACCOUNT')}
        ($UserFlag  -BOR 0x0800)  {[void]$List.Add('INTERDOMAIN_TRUST_ACCOUNT')}
        ($UserFlag  -BOR 0x1000)  {[void]$List.Add('WORKSTATION_TRUST_ACCOUNT')}
        ($UserFlag  -BOR 0x2000)  {[void]$List.Add('SERVER_TRUST_ACCOUNT')}
        ($UserFlag  -BOR 0x10000)  {[void]$List.Add('DONT_EXPIRE_PASSWORD')}
        ($UserFlag  -BOR 0x20000)  {[void]$List.Add('MNS_LOGON_ACCOUNT')}
        ($UserFlag  -BOR 0x40000)  {[void]$List.Add('SMARTCARD_REQUIRED')}
        ($UserFlag  -BOR 0x80000)  {[void]$List.Add('TRUSTED_FOR_DELEGATION')}
        ($UserFlag  -BOR 0x100000)  {[void]$List.Add('NOT_DELEGATED')}
        ($UserFlag  -BOR 0x200000)  {[void]$List.Add('USE_DES_KEY_ONLY')}
        ($UserFlag  -BOR 0x400000)  {[void]$List.Add('DONT_REQ_PREAUTH')}
        ($UserFlag  -BOR 0x800000)  {[void]$List.Add('PASSWORD_EXPIRED')}
        ($UserFlag  -BOR 0x1000000)  {[void]$List.Add('TRUSTED_TO_AUTH_FOR_DELEGATION')}
        ($UserFlag  -BOR 0x04000000)  {[void]$List.Add('PARTIAL_SECRETS_ACCOUNT')}
      }
      $List  -join ', '
    }

    Function  ConvertTo-SID {
        Param([byte[]]$BinarySID)
        (New-Object  System.Security.Principal.SecurityIdentifier($BinarySID,0)).Value
    }

    Function IsPasswordExpired {
      Param ($UserFlag)
      $Expired = $false
      #Write-Host "(PasswordExpired)Expired:" $Expired
      #Write-Host "(PasswordExpired)UserFlag:" $UserFlag
      Switch ($UserFlag) {
        ($UserFlag -BOR 0x800000) {$Expired = $true}
      }
      #Write-Host "(PasswordExpired)Expired:" $Expired
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
    
    $adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
    $adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
      $name = $_.Name
      if ($name -match "_pv676871") {
        #Write-Host ""
        Write-Host -BackgroundColor Cyan -ForegroundColor DarkBlue "Name:" $name
        $UserFlags = Convert-UserFlag $_.UserFlags[0]
        #Write-Host "UserFlags:" $UserFlags
        $PwdAge = [math]::Round($_.PasswordAge[0]/86400)
        Write-Host -BackgroundColor Cyan -ForegroundColor DarkBlue "PasswordAge:" $PwdAge
        if (IsPasswordExpired $_.UserFlags[0]) {
          Write-Host "PasswordExpired: true"
          #Write-Host "net user $name /expires:never" 
        }
        #$_.put("PasswordAge", 0)
        #$_.SetInfo()
        if (IsPasswordDontExpired $_.UserFlags[0]) {
          Write-Host "PasswordDontExpired: true"
          #Write-Host "wmic useraccount WHERE Name='$name' set PasswordExpires=true"
          #Write-Host "wmic useraccount WHERE Name='$name' set PasswordAge=50"
          #Write-Host "net user $name /expires:never" 
        }
    
        #$iexplorer = new-object -com InternetExplorer.Application -strict # Create instance of IE
        #$iexplorer.Visible = $true
      }
    }
    
    
    
    
  }

  Process  {
    ForEach  ($Computer in  $Computername) {
      $adsi  = [ADSI]"WinNT://$Computername"
      $adsi.Children | where {$_.SchemaClassName -eq  'user'} |  ForEach {
        #Write-Host "Name:" $_.Name 
        $Username = "powershell"
        if ($_.Name -eq $Username) {
          [pscustomobject]@{
            UserName = $_.Name[0]
            SID = ConvertTo-SID -BinarySID $_.ObjectSID[0]
            PasswordAge = [math]::Round($_.PasswordAge[0]/86400)
            LastLogin = If ($_.LastLogin[0] -is [datetime]){$_.LastLogin[0]}Else{'Never logged  on'}
            UserFlags = Convert-UserFlag  -UserFlag $_.UserFlags[0]
            MinPasswordLength = $_.MinPasswordLength[0]
            MinPasswordAge = [math]::Round($_.MinPasswordAge[0]/86400)
            MaxPasswordAge = [math]::Round($_.MaxPasswordAge[0]/86400)
            BadPasswordAttempts = $_.BadPasswordAttempts[0]
            MaxBadPasswords = $_.MaxBadPasswordsAllowed[0]
          }
          $_ | Select *  
        }

        <# 
        $name = $_.Name
        if ($name -match "_pv676871") {
          #Write-Host ""
          Write-Host -BackgroundColor Cyan -ForegroundColor DarkBlue "Name:" $name
          $UserFlags = Convert-UserFlag $_.UserFlags[0]
          #Write-Host "UserFlags:" $UserFlags
          $PwdAge = [math]::Round($_.PasswordAge[0]/86400)
          Write-Host -BackgroundColor Cyan -ForegroundColor DarkBlue "PasswordAge:" $PwdAge
          if (IsPasswordExpired $_.UserFlags[0]) {
            Write-Host "PasswordExpired: true"
            #Write-Host "net user $name /expires:never" 
          }
          #$_.put("PasswordAge", 0)
          #$_.SetInfo()
          if (IsPasswordDontExpired $_.UserFlags[0]) {
            Write-Host "PasswordDontExpired: true"
            #Write-Host "wmic useraccount WHERE Name='$name' set PasswordExpires=true"
            #Write-Host "wmic useraccount WHERE Name='$name' set PasswordAge=50"
            #Write-Host "net user $name /expires:never" 
          }
      
          #$iexplorer = new-object -com InternetExplorer.Application -strict # Create instance of IE
          #$iexplorer.Visible = $true
          #>
        }
      }
    }
  }
}

