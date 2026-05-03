<#
.SYNOPSIS
	Citrix: Sets machine metadata
.DESCRIPTION
	Updates or adds metadata associated with a specific Citrix machine.
.PARAMETER MachineName
	The name of the machine.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixMachineMetadata.ps1 -MachineName "CONTOSO\PC01" -Map @{ 'Location' = 'Bld4' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerMachineMetadata -MachineName $MachineName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for machine '$MachineName'."
} catch {
	Write-Error $_
	exit 1
}