<#
.SYNOPSIS
	Opens Microsoft Office 365
.DESCRIPTION
	This script launches the Web browser with the Microsoft Office 365 website.
.EXAMPLE
	PS> ./open-office-365.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://portal.office.com"
exit 0
