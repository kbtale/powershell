<#
.SYNOPSIS
	Lists the current weather forecast
.DESCRIPTION
	This PowerShell script lists the current weather forecast.
.PARAMETER GeoLocation
	Specifies the geographic location to use
.EXAMPLE
	PS> ./weather Paris
.CATEGORY System
#>

#Requires -Version 5.1

param([string]$GeoLocation = "")

try {
	(Invoke-WebRequest http://wttr.in/$GeoLocation -userAgent "curl" -useBasicParsing).Content
	exit 0
} catch {
throw
}
