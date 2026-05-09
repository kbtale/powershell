<#
.SYNOPSIS
	Plays a bee sound
.DESCRIPTION
	This PowerShell script plays a bee sound.
.EXAMPLE
	PS> ./play-bee-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/bee.mp3"
exit 0
