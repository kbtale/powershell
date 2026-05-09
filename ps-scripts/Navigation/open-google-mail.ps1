<#
.SYNOPSIS
	Opens Google Mail
.DESCRIPTION
	This PowerShell script launches the Web browser with the Google Mail website.
.EXAMPLE
	PS> ./open-google-mail.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://mail.google.com"
exit 0
