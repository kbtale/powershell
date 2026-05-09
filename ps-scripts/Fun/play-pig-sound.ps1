<#
.SYNOPSIS
	Plays a pig sound
.DESCRIPTION
	This PowerShell script plays a pig sound.
.EXAMPLE
	PS> ./play-pig-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/pig.mp3"
exit 0
