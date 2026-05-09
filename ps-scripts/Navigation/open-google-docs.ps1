<#
.SYNOPSIS
	Opens Google Docs
.DESCRIPTION
	This PowerShell script launches the Web browser with the Google Docs website.
.EXAMPLE
	PS> ./open-google-docs.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://docs.google.com"
exit 0
