<#
.SYNOPSIS
	List unused files in a directory tree
.DESCRIPTION
	This PowerShell script scans a directory tree and lists unused files (no read/write access since a number of days).
.PARAMETER path
	Specifies the path to the directory tree (current working dir by default)
.PARAMETER days
	Specifies the number of days (100 by default)
.EXAMPLE
	PS> ./list-unused-files.ps1 C:\Windows
.CATEGORY System
#>

#Requires -Version 5.1

param([string]$path = "$PWD", [int]$days = 100)

try {
	$stopWatch = [system.diagnostics.stopwatch]::startNew()

	$path = Resolve-Path "$path"
	Write-Progress "Scanning $path for unused files..."

	$cutOffDate = (Get-Date).AddDays(-$Days)
	[int]$count = 0
	Get-ChildItem -path $path -recurse | Where-Object {$_.LastAccessTime -le $cutOffDate} | Foreach-Object {
		"$($_.FullName)"
		$count++
	}
	Write-Progress -completed " "
	[int]$elapsed = $stopWatch.Elapsed.TotalSeconds
	"✅ $count unused files at 📂$path (no access for $days days, took $($elapsed)s)."
	exit 0
} catch {
throw
}
