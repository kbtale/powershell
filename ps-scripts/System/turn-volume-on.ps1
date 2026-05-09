<#
.SYNOPSIS
	Turn audio on
.DESCRIPTION
	This PowerShell script immediately unmutes the audio output.
.EXAMPLE
	PS> .\turn-volume-on
.CATEGORY System
#>

#Requires -Version 5.1

try {
	$obj = new-object -com wscript.shell
	$obj.SendKeys([char]173)
	exit 0
} catch {
throw
}
