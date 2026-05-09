<#
.SYNOPSIS
	Lists verbs in PowerShell
.DESCRIPTION
	This PowerShell script lists all allowed/recommended verbs in PowerShell.
.EXAMPLE
	PS> ./list-powershell-verbs.ps1
		Verb        Group
		----        -----
		Add         Common
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Get-Verb | Sort-Object -Property Verb
	exit 0
} catch {
throw
}
