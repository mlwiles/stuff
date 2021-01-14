<# 
.SYNOPSIS 
Recursively looks at the contents of a directory and returns file list

.DESCRIPTION 
Created to help find some of the largest files that can be deleted to free up space on shared machines

.EXAMPLE
C:\tmp\find-bigfiles.ps1 -path c:\tmp -count 5

.PARAMETER path
   The path to the director to scan
.PARAMETER count
   The number of files to return

.LINK
   https://stackoverflow.com/questions/60039046/use-get-childitem-recurse-in-powershell-but-get-each-full-path-on-a-separate-li
   https://devblogs.microsoft.com/scripting/rounding-numberspowershell-style/

.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2020-12-17
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Identify largest files in a windows path
└─────────────────────────────────────────────────────────────────────────────────────────────┘
 
#> 
param (
   [Parameter(Mandatory=$true)][string]$path,
   [int]$count = 10
)


if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{ 
   Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
}

Write-Host "Checking files in the folder: $path"
$testpath = Test-Path -Path $path
if (-not $testpath) {
  Write-Host "Folder does not exist: $path" 
  exit 0
}

#traverse the directory, find the large files, cleanup huge decimal
Get-ChildItem -Path $path -Recurse -Force -File | 
   Select-Object -Property FullName,@{Name='SizeGB';Expression={[math]::Round($_.Length / 1GB,2)}}  |
   Sort-Object { $_.SizeGB } -Descending | select -First $count