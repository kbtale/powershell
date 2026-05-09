<#
.SYNOPSIS
	Closes OBS Studio
.DESCRIPTION
	This PowerShell script closes the OBS Studio application gracefully.
.EXAMPLE
	PS> ./close-obs-studio.ps1
.CATEGORY System
#>

#Requires -Version 5.1

TaskKill /im obs64.exe
if ($lastExitCode -ne 0) {
	& "$PSScriptRoot/speak-english.ps1" "Sorry, OBS Studio isn't running"
	exit 1
}
exit 0
