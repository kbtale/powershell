<#
.SYNOPSIS
	Opens the OpenStreetMap website
.DESCRIPTION
	This script launches the Web browser with the OpenStreetMap website.
.EXAMPLE
	PS> ./open-street-map.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://www.openstreetmap.org"
exit 0
