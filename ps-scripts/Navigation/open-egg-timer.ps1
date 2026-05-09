<#
.SYNOPSIS
	Opens an egg timer
.DESCRIPTION
	This PowerShell script launches the Web browser with the eggtimer website.
.EXAMPLE
	PS> ./open-egg-timer
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://e.ggtimer.com"
exit 0
