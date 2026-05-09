<#
.SYNOPSIS
	Halts the computer (needs admin rights)
.DESCRIPTION
	This script halts the local computer immediately (needs admin rights).
.EXAMPLE
	PS> ./poweroff
.CATEGORY System
#>

#Requires -Version 5.1

#Requires -RunAsAdministrator

try {
	if ($IsLinux) {
		sudo shutdown
	} else {
		Stop-Computer
	}
	exit 0
} catch {
throw
}
