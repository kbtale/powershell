<#
.SYNOPSIS
	Plays a horse sound
.DESCRIPTION
	This PowerShell script plays a horse sound.
.EXAMPLE
	PS> ./play-horse-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/horse.mp3"
exit 0
