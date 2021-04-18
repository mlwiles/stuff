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

$generateonly = 1

for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "-execute") { 
        $generateonly = 0 
    }
}

if ($generateonly -eq 0) {

    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
    }

    $ipaddr = Get-NetIPAddress -InterfaceAlias 'Array Networks SSL VPN' | % { $_.ToString() }
    Write-Output ("Determined that the ip interface for your 'Array Networks SSL VPN' is: $ipaddr")

    $command = "route delete 10.0.0.0"
    Write-Output ("COMMENT: The command '$command' will report 'The route deletion failed: Element not found.' if the 10.0.0.0 route does not exist")
    Write-Output ("** Executing the command: $command **")
    iex $command

    $command = "route add 10.127.196.0 MASK 255.255.255.0 $ipaddr"
    Write-Output ("COMMENT:  The command '$command' will report 'The route addition failed: The object already exists.' if the route already exists")
    Write-Output ("** Executing the command: $command **")
    iex $command
} else {
    $ipaddr = Get-NetIPAddress -InterfaceAlias 'Array Networks SSL VPN' | % { $_.ToString() }
    Write-Output ("Determined that the ip interface for your 'Array Networks SSL VPN' is: $ipaddr")
    Write-Output ("Determined the following routes to be ran manually:")
    $command = "route delete 10.0.0.0"
    Write-Output ("$command")
    $command = "route add 10.127.196.0 MASK 255.255.255.0 $ipaddr"
    Write-Output ("$command")
}
