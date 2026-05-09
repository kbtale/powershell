<#
.SYNOPSIS
	Opens FlightRadar24
.DESCRIPTION
	This PowerShell script launches the Web browser with the FlightRadar24 website.
.EXAMPLE
	PS> ./open-flight-radar.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://www.flightradar24.com"
exit 0
