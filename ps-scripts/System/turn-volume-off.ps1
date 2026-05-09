<#
.SYNOPSIS
	Turn audio off
.DESCRIPTION
	This PowerShell script mutes the default audio device immediately.
.EXAMPLE
	PS> ./turn-volume-off
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
