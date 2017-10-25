# check-process-sandbox.ps1
# Generates a summary of sandbox restrictions for a given process
# Usage: .\check-process-sandbox.ps1 <pid>
#
# <pid> pid of process to check
#
# Author: Paul Theriault <pauljt@mozilla.com>

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=0)]
   [string]$processId
)

Write-Host "Testing process $($processId) migigations"
$process = Get-NtProcess $ProcessId
$token = Get-NtToken -Primary -pid $processId

Write-Host "Integrity Level $($token.IntegrityLevel)"
Write-Output $process.Mitigations 

#Check access to registry
$registryPath = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\"
$regAccess = Get-AccessibleKey -ProcessIds $processId -Win32Path $RegistryPath -Recurse

Write-Host "Number of keys accessible in $($registryPath): $($regAccess.length)"

#Check access to files
$fileSystemPath = "C:\ProgramData"
$fileAccess = Get-AccessibleFile -ProcessIds $processId -Win32Path $fileSystemPath -Recurse -Tokens $token  -AccessRights GenericWrite -DirectoryAccessRights GenericWrite

Write-Host "Number of file accessible in $($fileSystemPath):$($fileAccess.length)"
