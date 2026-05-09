<#
.SYNOPSIS
	Toggle Scroll Lock
.DESCRIPTION
	This PowerShell script toggles the Scroll Lock key state.
.EXAMPLE
	PS> ./toggle-scroll-lock
.CATEGORY System
#>

#Requires -Version 5.1

try {
	$wsh = New-Object -ComObject WScript.Shell
	$wsh.SendKeys('{SCROLLLOCK}')
	exit 0
} catch {
throw
}
