<#
.SYNOPSIS
	Lists all environment variables
.DESCRIPTION
	This PowerShell script lists all environment variables.
.EXAMPLE
	PS> ./list-environment-variables.ps1
		Name                           Value
		----                           -----
		ALLUSERSPROFILE                C:\ProgramData
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Get-ChildItem env:
	exit 0
} catch {
throw
}
