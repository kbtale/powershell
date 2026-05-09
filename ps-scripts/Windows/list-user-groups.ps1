<#
.SYNOPSIS
	Lists the user groups
.DESCRIPTION
	This PowerShell script lists the user groups of the local computer.
.EXAMPLE
	PS> ./list-user-groups.ps1
		Name                 Description
		----                 -----------
		Administrators       Administrators have complete and unrestricted access to the computer/domain
.CATEGORY Windows
#>

#Requires -Version 5.1

try {
	Get-LocalGroup
	exit 0
} catch {
throw
}
