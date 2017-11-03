<#
Author: cr@mozilla.com

.SYNOPSIS
Get all Firefox process objects

.DESCRIPTION
Get-Foxes filters Win32_Process for the filename of firefox.exe and adds a bool
property called IsFirefoxParent to easily differentiate between parent and content
processes.

.PARAMETER Complete
Make Get-Foxes dump the complete Win32_Process objects instead of just a subset.

.EXAMPLE
Show all Firefox parent processes:

Get-Foxes | where {$_.IsFirefoxParent}

Show all Firefox content processes:

Get-Foxes | where {-not $_.IsFirefoxParent}


.NOTES
This cmdlet was developed primarily for analysing the Firefox process and has not been
specifically tested for other use cases.
#>

param([Switch] $Complete)

$all_procs = Get-WmiObject Win32_Process
$all_foxes = $all_procs | Where-Object {$_.name -eq "firefox.exe"}

$pids = $all_foxes | foreach {[int] $_.ProcessId}
$ppids = $all_foxes | foreach {[int] $_.ParentProcessId}

$parent_foxes = @()
foreach ($p in $ppids) {
    $pr = $all_foxes | where {$_.ProcessId -eq $p}
    if ($pids.Contains($p) -and -not $parent_foxes.Contains($pr)) {
            $parent_foxes += $pr
            $pr | Add-Member -MemberType NoteProperty -Name IsFirefoxParent -Value $true
    }
}

$content_foxes = @()
foreach ($p in $pids) {
    $pr = $all_foxes | where {$_.ProcessId -eq $p}
    if (-not $ppids.Contains($p) -and -not $content_foxes.Contains($pr)) {
            $content_foxes += $pr
            $pr | Add-Member -MemberType NoteProperty -Name IsFirefoxParent -Value $false
    }
}

# $exe_path = $parent_foxes[0].ExecutablePath

if ($Complete) {
    $all_foxes
} else {
    $all_foxes | Select-Object -Property Name,ExecutablePath,ProcessId,ParentProcessId,IsFirefoxParent
}
