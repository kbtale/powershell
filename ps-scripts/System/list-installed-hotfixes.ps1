<#
.SYNOPSIS
	Lists the installed hotfixes
.DESCRIPTION
	This PowerShell script lists the installed hotfixes.
.EXAMPLE
	PS> ./list-installed-hotfixes.ps1
		Source        Description      HotFixID      InstalledBy          InstalledOn
		------        -----------      --------      -----------          -----------
		MyPC          Update           KB5054977     NT AUTHORITY\SYSTEM  4/10/2025 12:00:00 AM
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Get-Hotfix
	exit 0
} catch {
throw
}
