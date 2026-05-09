<#
.SYNOPSIS
	Plays a donkey sound
.DESCRIPTION
	This PowerShell script plays a donkey sound.
.EXAMPLE
	PS> ./play-donkey-sound
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/donkey.mp3"
exit 0
