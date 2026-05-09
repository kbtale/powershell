<#
.SYNOPSIS
	Opens a fire place website
.DESCRIPTION
	This PowerShell script launches the Web browser with a fire place website.
.EXAMPLE
	PS> ./open-fire-place
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://freefireplaces.com"
exit 0
