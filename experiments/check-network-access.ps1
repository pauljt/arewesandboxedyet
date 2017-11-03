# check-network-access.ps1
# Usage: .\check-file-access.ps1 -targetpid <pid> 
#
#
# Author: Paul Theriault <pauljt@mozilla.com>


[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$targetpid
)

#obtain a token for the target process
$token = Get-NtToken -Primary -pid $targetpid

if(!$token)
{
    Write-Host "Error: unable to obtain process token (check the target pid, are you running powershell as admin?)"
    exit
}

Get-AccessibleFile -Win32Path $testpath -Recurse -Tokens $token  -AccessRights GenericWrite -DirectoryAccessRights GenericWrite



