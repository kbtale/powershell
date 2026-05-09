<#
.SYNOPSIS
	Plays an elephant sound
.DESCRIPTION
	This PowerShell script plays an elephant sound.
.EXAMPLE
	PS> ./play-elephant-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/elephant.mp3"
exit 0
