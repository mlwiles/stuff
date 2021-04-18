
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

$nics = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()
foreach ($nic in $nics) {
    $name = $nic.name
    if ($name -eq "Array Networks SSL VPN") {
        $props = $nic.GetIPProperties()
        $addresses = $props.UnicastAddresses
        foreach ($addr in $addresses) {
            $ipaddr = $($addr.Address.IPAddressToString)
            Write-Output ("Determined that the ip interface for your 'Array Networks SSL VPN' is: $ipaddr")
            Write-Output ("Determined the following routes to be ran manually:")
            $command = "route delete 10.0.0.0"
            Write-Output ("$command")
            $command = "route add 10.0.0.0 MASK 255.255.255.0 $ipaddr"
            Write-Output ("$command")
        }
    }
}