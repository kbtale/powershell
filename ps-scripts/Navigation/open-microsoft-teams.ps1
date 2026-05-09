<#
.SYNOPSIS
	Launches the Microsoft Teams app
.DESCRIPTION
	This script launches the Microsoft Teams application.
.EXAMPLE
	PS> ./open-microsoft-teams.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start-Process msteams:
	exit 0
} catch {
throw
}
