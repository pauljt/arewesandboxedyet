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

$DEVICE_TEST_PATH = "\"
$FILE_TEST_PATH = "C:\ProgramData" #win32path
$REGISTRY_TEST_PATH ="\Registry\Machine\Software\Microsoft"

[hashtable]$Return = @{} 

Write-Host "Testing process $($processId) migigations"
$process = Get-NtProcess $ProcessId
$token = Get-NtToken -Primary -pid $processId

# process details
$Return.integrity = ($token.IntegrityLevel)
$Return.mitigations = $process.Mitigations |Select-Object *
#todo get job restrictions
#todo SIDs, RIDS etc

# test access to windows objects
$Return.regkeys = Get-AccessibleKey $REGISTRY_TEST_PATH  -ProcessIds $processId -Recurse -AccessRights GenericWrite
$Return.files = Get-AccessibleFile -ProcessIds $processId -Win32Path $FILE_TEST_PATH -Recurse -Tokens $token  -AccessRights GenericWrite -DirectoryAccessRights GenericWrite
$Return.objects = Get-AccessibleObject -Recurse -AccessRights GenericWrite -ProcessIds $processId -Win32Path \ 
$Return.alpc =  Get-AccessibleAlpcPort -ProcessIds $processId
$Return.devices = Get-AccessibleDevice $deviceRoot -Recurse -AccessRights GenericWrite -ProcessIds $processId
$Return.pipes = Get-AccessibleNamedPipe -ProcessIds $processId 
$Return.services = Get-AccessibleService -ProcessIds $processId
$Return.processes = Get-AccessibleProcess -ProcessIds $processId

################  Check if process has the ability to spawn a new process
$Return.createProcess = $FALSE;
# Launch a cmd prompt with the token
$newProcess = New-Win32Process -Token $ptoken -CommandLine c:\Windows\System32\cmd.exe
if($newProcess){
    $Return.createProcess = $TRUE;
}

Return $Return