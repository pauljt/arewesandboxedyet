# check-file-access.ps1
# Usage: .\check-file-access.ps1 -targetpid <pid> [-WriteOnly]
#
# -targetpid pid of process to check
#
# -testpath path to test (recursively), defaults to c:\
#
# - WriteOnly Only check for write access.
#
# Author: Paul Theriault <pauljt@mozilla.com>


[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=0)]
   [string]$targetpid,
	

   [Parameter(Mandatory=$False,Position=1)]
   [string]$testpath = "C:\",
   
   [switch]$WriteOnly
)



#obtain a token for the target process
$token = Get-NtToken -Primary -pid $targetpid

if(!$token)
{
    Write-Host "Error: unable to obtain process token (check the target pid, are you running powershell as admin?)"
    exit
}


if($WriteOnly)
{
    Write-Host "Testing process $($targetpid) has WRITE access $($testpath) "
    Get-AccessibleFile -Win32Path $testpath -Recurse -Tokens $token  -AccessRights GenericWrite -DirectoryAccessRights GenericWrite
} 
else{
    Write-Host "Testing process $($targetpid) can ANY access $($testpath) "
    Get-AccessibleFile -Win32Path $testpath -Recurse -Tokens $token  
}


