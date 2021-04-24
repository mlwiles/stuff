
<# 
.SYNOPSIS 
 ESX Host looking for firmware versions
 
.DESCRIPTION 
 
.EXAMPLE
 
.PARAMETER  

.LINK
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2021-01-27
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : ESX Host looking for firmware versions
└─────────────────────────────────────────────────────────────────────────────────────────────┘
#>

#setup vcenter connection
$vCenterServer = Read-Host -Prompt "vCenter FQDN"
Connect-VIServer -Server $vCenterServer
$arrOutput = @()
#get list of hosts in vcenter
$esxHostList = Get-VMHost | Where-Object {$_.PowerState -eq "PoweredOn"}
foreach ($esxHost in $esxHostList)
{
    #get card info (4 port cards, only grabbing info for first interface)
    $nicList = Get-VMHost $esxHost | Get-VMHostNetworkAdapter | Where-Object { $_.Name -eq "vmnic0" -or $_.Name -eq "vmnic4"} 
    $esxcli  = Get-VMHost $esxHost | Get-EsxCli
    foreach ($nic in $nicList)
    {
        #create new object to store nic info we want and slap them into an array
        $objNic = New-Object System.Object
        $objDriverInfo = ($esxcli.network.nic.get($nic.Name)).DriverInfo
        $objNic | Add-Member -type NoteProperty -name HostName -Value $esxHost.Name
        $objNic | Add-Member -type NoteProperty -name VMNicName -Value $nic.Name
        $objNic | Add-Member -type NoteProperty -name DriverName -Value $objDriverInfo.Driver
        $objNic | Add-Member -type NoteProperty -name DriverVersion -Value $objDriverInfo.Version
        $objNic | Add-Member -type NoteProperty -name FirmwareVersion -Value $objDriverInfo.FirmwareVersion
        $arrOutput += $objNic
    }
}
#dump output
$arrOutput | Export-Csv blah.csv
#cleanup
Disconnect-VIServer -Server $vCenterServer