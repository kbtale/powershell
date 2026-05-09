<#
.SYNOPSIS
	Toggle Num Lock
.DESCRIPTION
	This PowerShell script toggles the Num Lock key state.
.EXAMPLE
	PS> ./toggle-num-lock
.CATEGORY System
#>

#Requires -Version 5.1

try {
	$wsh = New-Object -ComObject WScript.Shell
	$wsh.SendKeys('{NUMLOCK}')
	exit 0
} catch {
throw
}
