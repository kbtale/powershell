<#
.SYNOPSIS
	Opens Google Find My Device
.DESCRIPTION
	This PowerShell script launches the Web browser with the Google Find My Device website.
.EXAMPLE
	PS> ./locate-my-phone.ps1
.CATEGORY Navigation
#>

#Requires -Version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://www.google.com/android/find"
exit 0
