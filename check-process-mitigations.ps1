# check-process-mitigations.ps1
# Usage: .\check-process-mitgations.ps1 <pid>
#
# <pid> pid of process to check
#
# Author: Paul Theriault <pauljt@mozilla.com>

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=0)]
   [string]$ProcessId
)

Write-Host "Testing process $($ProcessId) migigations"
$proc = Get-NtProcess $ProcessId 
Write-Output $proc.Mitigations 



