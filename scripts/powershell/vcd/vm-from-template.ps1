########################################################################################################################
#Script to create a Cloud VM from a template 
########################################################################################################################
# https://code.vmware.com/samples/1166/powercli-script-to-create-a-vm-in-vcd-using-a-template

# Michael Wiles - mwiles@us.ibm.com
# 2020/10/12
# VCD investigations

#Setting up the powercli environment
C:\"Program Files (x86)"\VMware\Infrastructure\"vSphere PowerCLI"\Scripts\Initialize-PowerCLIEnvironment.ps1

#Connecting to the CI Server

Connect-CIServer -server $hostname -User $username -Password $password

#Reading the required values from a .csv file stored in a specific location.Change the location accordingly
#OrgName : It is the VDC name where we want the VM to be powered on
#TemplateName : Name of the Template which is used for the VM deployment
#VMName  : The Name to be used for the new VM creation
#ComputerName : The computer name that has to be assigned to the newly created VM

$vcloud_info = Import-Csv c:\scripts\info.csv
$orgvdcsName = $vcloud_info.OrgName
$TemplateName = $vcloud_info.TemplateName
$VMName = $vcloud_info.VMName
$CompName = $vcloud.ComputerName


$vapp =  Get-CIVApp -OrgVdc $orgvdcsName
$vmtemplate = Get-CIVMTemplate -Name $TemplateName

New-CIVM -VApp $vapp.name -VMTemplate $vmtemplate.Name -Name $VMName -ComputerName $CompName

$vappnetwork = Get-CIVApp -Name $vapp.Name | Get-CIVAppNetwork 
Get-CIVM -Name $VMName | Get-CINetworkAdapter | Set-CINetworkAdapter -VAppNetwork $vappnetwork -IPAddressAllocationMode Pool -Connected $true

Get-CIVM -Name $VMName | Start-CIVM