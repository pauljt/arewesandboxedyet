#Sandbox-Utils
#
# Functions for testing process sandboxing
# Author: Paul Theriault <pauljt@mozilla.com>

function Do-Something {

  param($Thing)

  Write-Output "I did something to $Thing"

  }

# GetStatsForProcess
# Generates a summary of sandbox restrictions for a given process
#
# $ProcessId pid of process to check
function GetStatsForProcess($ProcessId){

    $DEVICE_TEST_PATH = "\"
    $FILE_TEST_PATH = "C:\ProgramData" #win32path
    $REGISTRY_TEST_PATH ="\Registry\Machine\Software\Microsoft"
    $NTOBJECTRMANAGER_PATH = "C:\code\sandbox-attacksurface-analysis-tools\bin\Release\NtObjectManager\NtObjectManager.psd1"


    #ensure NtObjectManager module is loaded
    $NtObjectManagerLoaded = Get-Module -Name NtObjectManager
    if($NtObjectManagerLoaded -eq $null){
        Write-Host "NtObjectManager Not FOund: attempting to load module..."
        Import-Module $NTOBJECTRMANAGER_PATH
    }

    if($NtObjectManagerLoaded -eq $null){
        Write-Host "NtObjectManager not present and couldnt be loaded, exiting..."
        Quit
    }


    [hashtable]$Return = @{} 

    $process = Get-NtProcess $ProcessId

    Write-Host "Target process: $($process.Name) ($($process.Pid))"

    Write-Host "Testing process migigations"
    $token = Get-NtToken -Primary -pid $processId

    # process details
    Write-Host "Getting process $($processId) migigations"
    $Return.integrity = ($token.IntegrityLevel)
    $Return.mitigations = $process.Mitigations |Select-Object *
    #todo get job restrictions
    #todo SIDs, RIDS etc

    # test access to windows objects
    $Return.regkeys = Get-AccessibleKey $REGISTRY_TEST_PATH  -ProcessIds $processId -Recurse -AccessRights GenericWrite
    $Return.files = Get-AccessibleFile -ProcessIds $processId -Win32Path $FILE_TEST_PATH -Recurse -Tokens $token  -AccessRights GenericWrite -DirectoryAccessRights GenericWrite
    $Return.objects = Get-AccessibleObject -Recurse -AccessRights GenericWrite -ProcessIds $processId -Win32Path \ 
    $Return.alpc =  Get-AccessibleAlpcPort -ProcessIds $processId
    $Return.devices = Get-AccessibleDevice $DEVICE_TEST_PATH -Recurse -AccessRights GenericWrite -ProcessIds $processId
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
}


function getProcessType($process){
    $type = $process.CommandLine.split(" ")[-1]
    if($type -ne "tab"){
        return $type
    }
    else{
        #TODO: get the sub-type (file, privileged, web extension, ) 
        return $type
    }
}