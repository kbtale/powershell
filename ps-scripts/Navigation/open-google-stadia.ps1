<#
.SYNOPSIS
	Opens Google Stadia
.DESCRIPTION
	This PowerShell script launches the Web browser with the Google Stadia website.
.EXAMPLE
	PS> ./open-google-stadia.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://stadia.google.com"
exit 0
