<#
.SYNOPSIS
	Opens the Startpage website
.DESCRIPTION
	This script launches the Web browser with the Startpage website.
.EXAMPLE
	PS> ./open-start-page.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://www.startpage.com"
exit 0
