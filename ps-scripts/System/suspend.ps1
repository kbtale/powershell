<#
.SYNOPSIS
	Suspends the computer
.DESCRIPTION
	This PowerShell script suspends the local computer immediately.
.EXAMPLE
	PS> ./suspend
.CATEGORY System
#>

#Requires -Version 5.1

try {
	"Bye bye."
	& rundll32.exe powrprof.dll,SetSuspendState 0,1,0
	exit 0
} catch {
throw
}
