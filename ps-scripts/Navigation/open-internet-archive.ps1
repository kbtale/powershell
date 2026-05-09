<#
.SYNOPSIS
	Opens the Internet Archive website
.DESCRIPTION
	This script launches the Web browser with the Internet Archive website.
.EXAMPLE
	PS> ./open-internet-archive.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://archive.org"
exit 0
