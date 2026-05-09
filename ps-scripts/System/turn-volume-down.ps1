<#
.SYNOPSIS
	Turns the volume down
.DESCRIPTION
	This PowerShell script turns the audio volume down (-10% by default).
.PARAMETER percent
	Specifies the percent number
.EXAMPLE
	PS> ./turn-volume-down
.CATEGORY System
#>

#Requires -Version 5.1

param([int]$percent = 10)

try {
	$obj = New-Object -com wscript.shell
	for ([int]$i = 0; $i -lt $percent; $i += 2) {
		$obj.SendKeys([char]174)
	}
	exit 0
} catch {
throw
}
