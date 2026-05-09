<#
.SYNOPSIS
	Plays a cat sound
.DESCRIPTION
	This PowerShell script plays a cat sound.
.EXAMPLE
	PS> ./play-cat-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/cat.mp3"
exit 0
