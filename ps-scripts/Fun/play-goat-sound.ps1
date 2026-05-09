<#
.SYNOPSIS
	Plays a goat sound
.DESCRIPTION
	This PowerShell script plays a goat sound.
.EXAMPLE
	PS> ./play-goat-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/goat.mp3"
exit 0
