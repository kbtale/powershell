<#
.SYNOPSIS
	Plays a wolf sound
.DESCRIPTION
	This PowerShell script plays a wolf sound.
.EXAMPLE
	PS> ./play-wolf-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/wolf.mp3"
exit 0
