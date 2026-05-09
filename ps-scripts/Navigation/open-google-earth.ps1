<#
.SYNOPSIS
	Opens Google Earth
.DESCRIPTION
	This PowerShell script launches the Web browser with the Google Earth website.
.EXAMPLE
	PS> ./open-google-earth.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://earth.google.com/web/"
exit 0
