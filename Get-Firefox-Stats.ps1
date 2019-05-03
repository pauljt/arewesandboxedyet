# $all_foxes = Get-WmiObject Win32_Process | Where-Object {$_.name -eq "firefox.exe" -and $_.CommandLine.Contains("-contentproc")}


[CmdletBinding()]
Param(
  [Parameter(Mandatory=$False,Position=0)]
   [string]$processName
)


. C:\code\arewesandboxedyet\Sandbox-Utils.ps1

$output_dir = "firefox"
$MAIN_EXE = "firefox.exe"
$PLUGIN_EXE = "plugin-container.exe"
$parent_process = Get-WmiObject Win32_Process | Where-Object {$_.name -eq $MAIN_EXE -and -not $_.CommandLine.Contains("-contentproc")}
$child_processes = Get-WmiObject Win32_Process | Where-Object {$_.ParentProcessId -eq $parent_process.ProcessId}

[hashtable]$unique_processes = @{} 
[hashtable]$results = @{} 


$child_processes.ForEach({
    $process_type = getProcessType($_)
    Write-host $process_type
    if(-not $unique_processes.ContainsKey($process_type)){
        $unique_processes.Add($process_type,$_)
    }
})

$unique_processes.keys.ForEach({
    $unique_processes.Item($_).processId
    $result = GetStatsForProcess -ProcessId $unique_processes.Item($_).processId
    $results.Add($_, $result)
})

rmdir -Recurse $output_dir
mkdir $output_dir

$results.keys.ForEach({
    $results.item($_) |ConvertTo-Json > $output_dir/$_.json
})






   
   
    
