<#
.SYNOPSIS
	Reboots the computer (needs admin rights)
.DESCRIPTION
	This PowerShell script reboots the local computer immediately (needs admin rights).
.EXAMPLE
	PS> ./reboot
.CATEGORY System
#>

#Requires -Version 5.1

#Requires -RunAsAdministrator

try {
	if ($IsLinux) {
		& sudo reboot
	} else {
		Restart-Computer
	}
	exit 0
} catch {
throw
}
