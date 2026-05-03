<#
.SYNOPSIS
	Citrix: Sets machine catalog metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix machine catalog.
.PARAMETER CatalogName
	The name of the machine catalog.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixCatalogMetadata.ps1 -CatalogName "VDI_Pool" -Map @{ 'Source' = 'MCS' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$CatalogName,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerCatalogMetadata -Name $CatalogName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for machine catalog '$CatalogName'."
} catch {
	Write-Error $_
	exit 1
}