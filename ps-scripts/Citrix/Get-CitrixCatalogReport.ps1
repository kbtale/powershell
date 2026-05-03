<#
.SYNOPSIS
	Citrix: Gets catalog report
.DESCRIPTION
	Retrieves a summarized report of all machine catalogs in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixCatalogReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerCatalog -ErrorAction Stop | Select-Object Name, AllocationType, ProvisioningType, UnassignedCount
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}