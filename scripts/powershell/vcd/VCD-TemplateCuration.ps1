# Setting up the powercli environment
# C:\"Program Files (x86)"\VMware\Infrastructure\"vSphere PowerCLI"\Scripts\Initialize-PowerCLIEnvironment.ps1
# https://code.vmware.com/docs/4721/cmdlet-reference
# Connecting to the CI Server

# Michael Wiles - mwiles@us.ibm.com
# 2020/10/12
# VCD investigations

$templateOrg = "TemplateCurationOrg"
$templateOrgVdc = "TemplateCurationVdc"

$templateOrgId = "ORG_ID"
$templateOrgVdc = "VDC_NAME"
$templateOrgVdIdc = "VDC_ID"

$hostname = "HOSTNAME"
$username = "USERNAME"
$password = "REDACTED"
$username
$ciServer = Connect-CIServer -server $hostname -org $templateOrgId -User $username -Password $password 

$templates = @{}
$templates.add( "centos7", "CentOS-7-Template-Official" )
$templates.add( "centos8", "CentOS-8-Template-Official" )
$templates.add( "rhel7", "RedHat-7-Template-Official" )
$templates.add( "rhel8", "RedHat-8-Template-Official" )
$templates.add( "win2016", "Windows-2016-Template-Official" )
$templates.add( "win2019", "Windows-2019-Template-Official" )

###########################################
$whichOne = "centos8"
$templateName = $templates[$whichOne]
$vmName = "vm-$whichOne"
$vappName = "vapp-$whichOne"
Write-Host "Getting Org ..."
#$publicCatalogOrg = Get-Org -Server $ciServer -Name "public-catalog"
$GetOrg = Get-Org -Server $ciServer -Name $templateOrgId
$GetOrg
Write-Host "Getting Public Catalog ..."
#$publicCatalog = Get-Catalog -Server $ciServer -Org $publicCatalogOrg -Name "Public Catalog"   
$publicCatalog = Get-Catalog -Server $ciServer -Name "Public Catalog"   
#$publicCatalog = Get-Catalog -Server $ciServer -Org $tempOrg -Name "Public Catalog"   
###########################################
$publicCatalog
$GetOrgVdc = Get-OrgVdc -Server $ciServer -Org $GetOrg -Name $templateOrgVdc
$GetOrgVdc

pause
# validate the vapp
$ciVApp = $null
Write-Host "Checking for VApp:$vappName ..."
try {
   $ciVApp =  Get-CIVApp -Server $ciServer -OrgVdc $templateOrgVdc -Name $vappName
}
catch {
   Write-Host "VApp:$vappName not found"
}
if ($ciVApp -eq $null) {
   Write-Host "Creating VApp:$vappName ..."
   $ciVApp =  New-CIVApp -Server $ciServer -OrgVdc $templateOrgVdc -Name $vappName
   Write-Host "VApp:$vappName created"
} else {
   Write-Host "VApp:$vappName found"
}

# validate the vm
$ciVm = $null
Write-Host "Checking for VM:$vmName ..."
try {
   #https://code.vmware.com/docs/4721/cmdlet-reference/doc/Get-CIVM.html?h=civm
   $ciVm = Get-CIVM  -Server $ciServer -Org $templateOrg -OrgVdc $templateOrgVdc -Name $vmName -VApp $vappName
} 
catch {
   Write-Host "VM:$vmName not found"
}
if ($ciVm -eq $null) {
   Write-Host "Getting VApp template:$templateName  ..."
   $ciVAppTemplate = Get-CIVAppTemplate -Server $ciServer -Catalog $publicCatalog -Name $templateName 
   Write-Host "Getting VM template:$vmName ..."
   $ciVMTemplate = Get-CIVMTemplate -Server $ciServer -VAppTemplate $ciVAppTemplate -Name $vmName
   Write-Host "Creating VM:$vmName ..."
   #https://code.vmware.com/docs/4721/cmdlet-reference/doc/New-CIVM.html?h=civm
   $ciVm =  New-CIVM -Server $ciServer -VMTemplate $ciVMTemplate -VApp $ciVApp -Name $vmName -ComputerName $vmName
   Write-Host "VM:$vmName created"
} else {
   Write-Host "VM:$vmName found"
}