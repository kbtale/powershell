<#
.SYNOPSIS
	Minimizes all windows
.DESCRIPTION
	This PowerShell script minimizes all open windows.
.EXAMPLE
	PS> ./minimize-all-windows.ps1
.CATEGORY System
#>

#Requires -Version 5.1

try {
	$shell = New-Object -ComObject "Shell.Application"
	$shell.minimizeall()
	exit 0
} catch {
throw
}
