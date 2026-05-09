<#
.SYNOPSIS
	Plays a cow sound
.DESCRIPTION
	This PowerShell script plays a cow sound.
.EXAMPLE
	PS> ./play-cow-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/cow.mp3"
exit 0
