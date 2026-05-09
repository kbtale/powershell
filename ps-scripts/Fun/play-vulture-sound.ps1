<#
.SYNOPSIS
	Plays a vulture sound
.DESCRIPTION
	This PowerShell script plays a vulture sound.
.EXAMPLE
	PS> ./play-vulture-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/vulture.mp3"
exit 0
