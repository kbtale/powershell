<#
.SYNOPSIS
	Toggle Caps Lock
.DESCRIPTION
	This PowerShell script toggles the Caps Lock key state.
.EXAMPLE
	PS> ./toggle-caps-lock
.CATEGORY System
#>

#Requires -Version 5.1

try {
	$wsh = New-Object -ComObject WScript.Shell
	$wsh.SendKeys('{CAPSLOCK}')
	exit 0
} catch {
throw
}
