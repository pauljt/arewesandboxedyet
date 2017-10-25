# Get-Sandbox-Stats.ps1
# Generates a summary of sandbox restrictions for a given process
# Usage: .\Get-Sandbox-Stats.ps1 <pid>
#
# <pid> pid of process to check
#
# Author: Paul Theriault <pauljt@mozilla.com>
# $all_foxes = Get-WmiObject Win32_Process | Where-Object {$_.name -eq "firefox.exe" -and $_.CommandLine.Contains("-contentproc")}

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=0)]
   [string]$processId
)

[hashtable]$Return = @{} 

Write-Host "Testing process $($processId) migigations"
$process = Get-NtProcess $ProcessId
$token = Get-NtToken -Primary -pid $processId

#Write-Host "Integrity Level $($token.IntegrityLevel)"
$Return.IntegrityLevel = ($token.IntegrityLevel)
#Write-Output $process.Mitigations 
$Return.Mitigations = $process.Mitigations |Select-Object *


#Check write access to registry
# HKEY_LOCAL_MACHINE\REGISTRY\MACHINE\SOFTWARE\Microsoft\DRM
$registryPath = "\Registry\Machine\Software\Microsoft"

$RegistryAccess = Get-AccessibleKey $RegistryPath  -ProcessIds $processId -Recurse -AccessRights GenericWrite

#Write-Host "Number of keys accessible in $($registryPath): $($RegistryAccess.length)"
$Return.RegistryAccess 

#Check access to files
$fileSystemPath = "C:\"
$fileAccess = Get-AccessibleFile -ProcessIds $processId -Win32Path $fileSystemPath -Recurse -Tokens $token  -AccessRights GenericWrite -DirectoryAccessRights GenericWrite

#Write-Host "Number of file accessible in $($fileSystemPath):$($fileAccess.length)"
$Return.FileSystemAccess = $fileAccess


#get Write accessible devices under \
$Return.DeviceAccess = Get-AccessibleDevice \ -Recurse -AccessRights GenericWrite -ProcessIds $processId


Return $Return 
