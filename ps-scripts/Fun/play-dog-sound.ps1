<#
.SYNOPSIS
	Plays a dog sound
.DESCRIPTION
	This PowerShell script plays a dog sound.
.EXAMPLE
	PS> ./play-dog-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/dog.mp3"
exit 0
