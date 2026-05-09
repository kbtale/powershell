<#
.SYNOPSIS
	Launches the Remote Desktop app
.DESCRIPTION
	This script launches the Remote Desktop application.
.EXAMPLE
	PS> ./open-remote-desktop.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start-Process ms-rd:
	exit 0
} catch {
throw
}
