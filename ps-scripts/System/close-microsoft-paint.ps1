<#
.SYNOPSIS
	Closes the Microsoft Paint app
.DESCRIPTION
	This PowerShell script closes the Microsoft Paint application gracefully.
.EXAMPLE
	PS> ./close-microsoft-paint.ps1
.CATEGORY System
#>

#Requires -Version 5.1

TaskKill /im mspaint.exe
if ($lastExitCode -ne 0) {
	& "$PSScriptRoot/speak-english.ps1" "Sorry, Microsoft Paint isn't running."
	exit 1
}
exit 0
