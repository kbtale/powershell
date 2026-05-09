<#
.SYNOPSIS
	Plays a frog sound
.DESCRIPTION
	This PowerShell script plays a frog sound.
.EXAMPLE
	PS> ./play-frog-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/frog.mp3"
exit 0
