<#
.SYNOPSIS
	Lists the PowerShell modules
.DESCRIPTION
	This PowerShell script lists the installed PowerShell modules.
.EXAMPLE
	PS> ./list-powershell-modules.ps1
		Name                             Version  ModuleType  ExportedCommands
		----                             -------  ----------  ----------------
		Microsoft.PowerShell.Management  3.1.0.0  Manifest    {Add-Computer, Add-Content, Checkpoint-Computer...}
.CATEGORY System
#>

#Requires -Version 5.1

try {
	Get-Module | Format-Table -property Name,Version,ModuleType,ExportedCommands
	exit 0
} catch {
throw
}
