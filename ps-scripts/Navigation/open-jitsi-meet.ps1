<#
.SYNOPSIS
	Opens the Jitsi Meet website
.DESCRIPTION
	This script launches the Web browser with the Jitsi Meet website.
.EXAMPLE
	PS> ./open-jitsi-meet.ps1
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://meet.jit.si/"
exit 0
