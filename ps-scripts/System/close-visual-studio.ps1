<#
.SYNOPSIS
	Closes the Visual Studio app
.DESCRIPTION
	This PowerShell script closes the Microsoft Visual Studio application gracefully.
.EXAMPLE
	PS> ./close-visual-studio.ps1
.CATEGORY System
#>

#Requires -Version 5.1

TaskKill /im devenv.exe
if ($lastExitCode -ne 0) {
	& "$PSScriptRoot/speak-english.ps1" "Sorry, Visual Studio isn't running."
	exit 1
}
exit 0
