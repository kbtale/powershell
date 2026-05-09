<#
.SYNOPSIS
	Wakes up an human
.DESCRIPTION
	This PowerShell script plays the sound of Big Ben to wake a human up.
.EXAMPLE
	PS> ./wake-up-human.ps1
		(listen and enjoy)
.CATEGORY Fun
#>

#Requires -Version 5.1

do {
	& "$PSScriptRoot/play-mp3.ps1" "$PSScriptRoot/data/sounds/Big Ben.mp3"
} while ($true)

