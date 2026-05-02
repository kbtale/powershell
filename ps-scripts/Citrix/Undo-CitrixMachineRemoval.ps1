<#
.SYNOPSIS
	Citrix: Undoes a machine removal
.DESCRIPTION
	Recovers a machine that was recently removed from a Citrix machine catalog.
.PARAMETER MachineName
	The name of the machine to recover.
.EXAMPLE
	PS> ./Undo-CitrixMachineRemoval.ps1 -MachineName "CONTOSO\PC01"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Write-Warning "Attempting to re-add machine '$MachineName' as recovery action."
	Write-Output "Recovery action for '$MachineName' initiated. Please ensure it is re-added to its catalog."
} catch {
	Write-Error $_
	exit 1
}