<# 
.SYNOPSIS 
 
 
.DESCRIPTION 
 
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2019-11-15 
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Kick out users that are potentially preventing others from logging in
└─────────────────────────────────────────────────────────────────────────────────────────────┘
 
#>

function Is-Numeric ($Value) {
   return $Value -match "^[\d\.]+$"
}

function Clean-Up ($Value) {
   $Value = $Value -split "Disc"
   $Value = $Value -replace '\s',''
   $Value = $Value -replace '\r',''
   $Value = $Value -replace '\n',''
   $Value = $Value -replace '\t',''
   $Value = $Value -replace '\\',''
   $Value = $Value -replace '`0',''
   $Value = $Value -replace '`a',''
   $Value = $Value -replace '`b',''
   $Value = $Value -replace '`e',''
   $Value = $Value -replace '`f',''
   $Value = $Value -replace '`n',''
   $Value = $Value -replace '`r',''
   $Value = $Value -replace '`t',''
   $Value = $Value -replace '`v',''
   return $Value
}

try {
   ## Find all sessions matching the empty username
   $sessions = qwinsta 
   foreach ($session in $sessions) {
      if (($session -notmatch "Active") -and ($session -notmatch "Conn") -and ($session -notmatch "Listen") -and ($session -notmatch "services") -and ($session -notmatch "USERNAME")) {
         $clean = Clean-Up($session -split "Disc")
         if (Is-Numeric($clean)) {
            $temp = [string]$clean
            $id = $temp.SubString(0,$temp.Length-1)
            Write-Host "Logging off session id [$id]"
            #logoff $id  #trying the RDUserLogoff instaed
            Invoke-RDUserLogoff -UnifiedSessionId $id -HostServer "Jumpdal1001" -Force 
         }
      }
   }

   #every unknown user has 4 processes that linger ... 
   #these two processes when killed seem to allow the user to be logged out 
   $command = 'taskkill /f /im LogonUI.exe'
   iex $command
   $command = 'taskkill /f /im winlogon.exe'
   iex $command

} catch {
   if ($_.Exception.Message -match 'No user exists') {
       Write-Host "The user is not logged in."
   } else {
       throw $_.Exception.Message
   }
}


