<#
.SYNOPSIS
	Plays a gorilla sound
.DESCRIPTION
	This PowerShell script plays a gorilla sound.
.EXAMPLE
	PS> ./play-gorilla-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/gorilla.mp3"
exit 0
