<#
.SYNOPSIS
	Opens Google Translate
.DESCRIPTION
	This PowerShell script launches the Web browser with the Google Translate website.
.EXAMPLE
	PS> ./open-google-translate.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://translate.google.com"
exit 0
