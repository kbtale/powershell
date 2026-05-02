<#
.SYNOPSIS
	Citrix: Gets a report of machine catalogs
.DESCRIPTION
	Retrieves a summarized list of all machine catalogs in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixCatalogReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$catalogs = Get-BrokerCatalog -ErrorAction Stop | Select-Object Name, AllocationType, ProvisioningType, UnassignedCount, UsedCount
	Write-Output $catalogs
} catch {
	Write-Error $_
	exit 1
}