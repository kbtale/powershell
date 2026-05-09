<#
.SYNOPSIS
	Opens Google News
.DESCRIPTION
	This PowerShell script launches the Web browser with the Google News website.
.EXAMPLE
	PS> ./open-google-news.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://news.google.com"
exit 0
