<#
.SYNOPSIS
	Replies to "Roll a dice"
.DESCRIPTION
	This PowerShell script rolls a dice and returns the number by text-to-speech (TTS).
.EXAMPLE
	PS> ./roll-a-dice
.CATEGORY Fun
#>

#Requires -Version 5.1

$Reply = "It's", "I get", "Now it's", "OK, I have" | Get-Random
$Number = "1", "2", "3", "4", "5", "6" | Get-Random

& "$PSScriptRoot/speak-english.ps1" "$Reply $Number."
exit 0
