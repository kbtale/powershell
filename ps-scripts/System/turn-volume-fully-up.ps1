<#
.SYNOPSIS
	Turns the volume fully up
.DESCRIPTION
	This PowerShell script turns the audio volume fully up to 100%.
.EXAMPLE
	PS> ./turn-volume-fully-up
.CATEGORY System
#>

#Requires -Version 5.1

try {
	$obj = New-Object -com wscript.shell
	for ([int]$i = 0; $i -lt 100; $i += 2) {
		$obj.SendKeys([char]175)
	}
	exit 0
} catch {
throw
}
