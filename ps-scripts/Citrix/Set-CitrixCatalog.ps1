<#
.SYNOPSIS
	Citrix: Updates a machine catalog
.DESCRIPTION
	Updates the properties or configuration of an existing Citrix machine catalog.
.PARAMETER Name
	The name of the catalog.
.PARAMETER Description
	The new description for the catalog.
.EXAMPLE
	PS> ./Set-CitrixCatalog.ps1 -Name "VDI_Pool" -Description "Main VDI Pool for staff"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$Description
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerCatalog -Name $Name -Description $Description -ErrorAction Stop
	Write-Output "Successfully updated machine catalog '$Name'."
} catch {
	Write-Error $_
	exit 1
}