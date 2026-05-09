<#
.SYNOPSIS
	Launches the Bing Maps app
.DESCRIPTION
	This PowerShell script launches the Bing Maps application.
.EXAMPLE
	PS> ./open-bing-maps
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	Start-Process bingmaps:
	exit 0
} catch {
throw
}
