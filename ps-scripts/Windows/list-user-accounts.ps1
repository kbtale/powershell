<#
.SYNOPSIS
	Lists user accounts
.DESCRIPTION
	This PowerShell script lists the user accounts on the local computer.
.EXAMPLE
	PS> ./list-user-accounts.ps1
.CATEGORY Windows
#>

#Requires -Version 5.1

try {
	if ($IsLinux) {
		& getent passwd
	} else {
		& net user
	}
	exit 0
} catch {
throw
}
