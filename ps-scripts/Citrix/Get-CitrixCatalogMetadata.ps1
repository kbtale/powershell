<#
.SYNOPSIS
	Citrix: Gets catalog metadata
.DESCRIPTION
	Retrieves metadata associated with a specific Citrix machine catalog.
.PARAMETER CatalogName
	The name of the machine catalog.
.EXAMPLE
	PS> ./Get-CitrixCatalogMetadata.ps1 -CatalogName "VDI_Catalog"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$CatalogName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerCatalogMetadata -Name $CatalogName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}