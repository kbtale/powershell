<#
.SYNOPSIS
	Plays a parrot sound
.DESCRIPTION
	This PowerShell script plays a parrot sound.
.EXAMPLE
	PS> ./play-parrot-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/parrot.mp3"
exit 0
