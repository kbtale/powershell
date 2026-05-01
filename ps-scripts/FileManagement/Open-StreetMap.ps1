<#
.SYNOPSIS
	Opens the OpenStreetMap website
.DESCRIPTION
	This script launches the Web browser with the OpenStreetMap website.
.EXAMPLE
	PS> ./open-street-map.ps1
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
.CATEGORY Open
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://www.openstreetmap.org"
exit 0 # success
