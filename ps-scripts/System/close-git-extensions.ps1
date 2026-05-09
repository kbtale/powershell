<#
.SYNOPSIS
	Closes the Git Extensions app
.DESCRIPTION
	This PowerShell script closes the Git Extensions application gracefully.
.EXAMPLE
	PS> ./close-git-extensions.ps1
.CATEGORY System
#>

#Requires -Version 5.1

TaskKill /im GitExtensions.exe
if ($lastExitCode -ne 0) {
	& "$PSScriptRoot/speak-english.ps1" "Sorry, Git Extensions isn't running."
	exit 1
}
exit 0
