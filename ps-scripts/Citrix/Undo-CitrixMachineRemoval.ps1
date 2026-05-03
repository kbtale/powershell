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
	[string]$MachineName,

	[Parameter(Mandatory = $true)]
	[string]$CatalogName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	New-BrokerMachine -MachineName $MachineName -CatalogName $CatalogName -ErrorAction Stop
	Write-Output "Successfully recovered machine '$MachineName' into catalog '$CatalogName'."
} catch {
	Write-Error $_
	exit 1
}