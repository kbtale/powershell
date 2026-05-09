<#
.SYNOPSIS
	Plays an elk sound
.DESCRIPTION
	This PowerShell script plays an elk sound.
.EXAMPLE
	PS> ./play-elk-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/elk.mp3"
exit 0
