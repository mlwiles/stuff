@echo off
ECHO #Write-Output "**********************************************************" > "c:\\template_update.ps1"
ECHO #Write-Output "****** COMMANDS TO CLEANUP THE WINDOWS UPDATE CACHE ******" > "c:\\template_update.ps1"
ECHO #Write-Output "**********************************************************" > "c:\\template_update.ps1"
ECHO #DISM.exe /Online /Cleanup-image /Restorehealth >> "c:\\template_update.ps1"
ECHO #fc /scannow >> "c:\\template_update.ps1"

ECHO #Write-Output "********************************************" >> "c:\\template_update.ps1"
ECHO #Write-Output "****** CONFIGURE WINDOWS TO USE WINRM ******" >> "c:\\template_update.ps1"
ECHO #Write-Output "********************************************" >> "c:\\template_update.ps1"
ECHO #$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1" >> "c:\\template_update.ps1"
ECHO #$file = "c:\\foransible.ps1" >> "c:\\template_update.ps1"
ECHO #(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file) >> "c:\\template_update.ps1"
ECHO #powershell.exe -ExecutionPolicy ByPass -File $file >> "c:\\template_update.ps1"

ECHO #Write-Output "********************************************************" >> "c:\\template_update.ps1"
ECHO #Write-Output "****** SET KMS/UPDATE SERVERS TO MICROSOFT PUBLIC ******" >> "c:\\template_update.ps1"
ECHO #Write-Output "********************************************************" >> "c:\\template_update.ps1"
ECHO #slmgr /ckms  >> "c:\\template_update.ps1" >> "c:\\template_update.ps1"
ECHO #slmgr /ato >> "c:\\template_update.ps1" >> "c:\\template_update.ps1"

ECHO Write-Output "**************************************************************" >> "c:\\template_update.ps1"
ECHO Write-Output "****** USING MICROSOFT WINDOWS UPDATE POWERSHELL MODULE ******" >> "c:\\template_update.ps1"
ECHO Write-Output "**************************************************************" >> "c:\\template_update.ps1"
ECHO Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot >> "c:\\template_update.ps1"


ECHO Write-Output "*****************************************" > "c:\\template_cleanup.ps1"
EECHO Write-Output "****** DELETE FROM COMMON FOLDERS ******" > "c:\\template_cleanup.ps1"
ECHO Write-Output "*****************************************" > "c:\\template_cleanup.ps1"
ECHO Get-ChildItem -Path "C:\Windows\Temp\" -Include * ^| Remove-Item -recurse  >> "c:\\template_cleanup.ps1"
ECHO Get-ChildItem -Path "$env:TEMP" -Include * ^| Remove-Item -recurse  >> "c:\\template_cleanup.ps1"

ECHO Write-Output "***********************************************************" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "****** WINDOWS DISK CLEANUP WITH ALL OPTIONS ENABLED ******" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "***********************************************************" >> "c:\\template_cleanup.ps1"
ECHO C:\\Windows\\System32\\cmd.exe /c Cleanmgr /sagerun:65535 >> "c:\\template_cleanup.ps1"

ECHO Write-Output "********************************************************" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "****** FORCE QUEUED ACTION TO OCCUR SYNCHRONOUSLY ******" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "********************************************************" >> "c:\\template_cleanup.ps1"
ECHO C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\ngen.exe executequeueditems >> "c:\\template_cleanup.ps1"

ECHO Write-Output "**************************************************************************************************************************" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "****** CLEAN UP COMPONENTS AUTOMATICALLY & REMOVE ALL SUPERSEDED VERSIONS of EVERY COMPONENT IN THE COMPONENT STORE ******" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "**************************************************************************************************************************" >> "c:\\template_cleanup.ps1"
ECHO C:\\Windows\\System32\\Dism.exe /online /cleanup-image /startcomponentcleanup /resetbase >> "c:\\template_cleanup.ps1"

ECHO Write-Output "*********************************************************************" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "****** WINDOWS EVENT VIEWER - CLEAR LOGS AND OPTIONALLY BACKUP ******" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "*********************************************************************" >> "c:\\template_cleanup.ps1"
ECHO C:\\Windows\\System32\\wevtutil.exe clear-log Application >> "c:\\template_cleanup.ps1"
ECHO C:\\Windows\\System32\\wevtutil.exe clear-log Security >> "c:\\template_cleanup.ps1"
ECHO C:\\Windows\\System32\\wevtutil.exe clear-log Setup >> "c:\\template_cleanup.ps1"
ECHO C:\\Windows\\System32\\wevtutil.exe clear-log System >> "c:\\template_cleanup.ps1"

ECHO Write-Output "******************************************************************" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "****** ZERO FREE SPACE (GOOD FOR VIRTUAL DISK OPTIMIZATION) ******" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "******************************************************************" >> "c:\\template_cleanup.ps1"
ECHO C:\\SDelete\\sdelete64 -accepteula -z c: >> "c:\\template_cleanup.ps1"

ECHO Write-Output "*************************************************************" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "****** SET KMS/UPDATE SERVERS TO VMWARE SOLUTIONS DNAT ******" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "*************************************************************" >> "c:\\template_cleanup.ps1"
ECHO slmgr /skms 52.117.132.4  >> "c:\\template_cleanup.ps1"
ECHO slmgr /ato >> "c:\\template_cleanup.ps1"

ECHO Write-Output "**************************************************************************" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "****** REMOVE SCRIPTS AND SHUTDOWN THE IMAGE IN PREP FOR TEMPLITIZE ******" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "**************************************************************************" >> "c:\\template_cleanup.ps1"
ECHO if (Test-Path c:\\template_update.ps1) { Remove-Item c:\\template_update.ps1 } >> "c:\\template_cleanup.ps1"
ECHO if (Test-Path c:\\foransible.ps1) { Remove-Item c:\\foransible.ps1 } >> "c:\\template_cleanup.ps1"
ECHO if (Test-Path c:\\template_cleanup.ps1) { Remove-Item c:\\template_cleanup.ps1 } >> "c:\\template_cleanup.ps1"
ECHO Clear-RecycleBin -Force >> "c:\\template_cleanup.ps1"

ECHO Write-Output "**************************************************************************************" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "C:\\Windows\\System32\\shutdown /s /t 0 /c ""Image Ready"" OR use terraform to cleanup" >> "c:\\template_cleanup.ps1"
ECHO Write-Output "**************************************************************************************" >> "c:\\template_cleanup.ps1"


