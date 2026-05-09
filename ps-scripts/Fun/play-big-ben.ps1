<#
.SYNOPSIS
	Plays the Big Ben sound
.DESCRIPTION
	This PowerShell script plays the sound of Big Ben.
.EXAMPLE
	PS> ./play-big-ben.ps1
		(listen and enjoy)
.CATEGORY Fun
#>

#Requires -Version 5.1

& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/Big Ben.mp3"
exit 0
