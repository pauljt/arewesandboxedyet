# check-registry-access.ps1
# Usage: .\check-registry-access.ps1 -targetpid <pid> -hive
#
# -targetpid pid of process to check
#
# -hivename path to test (recursively), defaults to c:\
#
# - WriteOnly Only check for write access.
#
# Author: Paul Theriault <pauljt@mozilla.com>


[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=0)]
   [string]$ProcessIds,
	
   [Parameter(Mandatory=$False,Position=1)]
   [string]$Pathname = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run"
)

Write-Host "Testing process $($targetpid) has registry access to $($Pathname) "
Get-AccessibleKey -ProcessIds $ProcessIds -Win32Path $Pathname -Recurse



