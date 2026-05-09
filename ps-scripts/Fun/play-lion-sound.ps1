<#
.SYNOPSIS
	Plays a lion sound
.DESCRIPTION
	This PowerShell script plays a lion sound.
.EXAMPLE
	PS> ./play-lion-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/lion.mp3"
exit 0
