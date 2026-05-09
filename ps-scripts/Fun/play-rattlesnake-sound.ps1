<#
.SYNOPSIS
	Plays a rattlesnake sound
.DESCRIPTION
	This PowerShell script plays a rattlesnake sound.
.EXAMPLE
	PS> ./play-rattlesnake-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/rattlesnake.mp3"
exit 0
