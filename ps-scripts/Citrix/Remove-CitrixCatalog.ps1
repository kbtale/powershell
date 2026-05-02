<#
.SYNOPSIS
	Citrix: Removes a machine catalog
.DESCRIPTION
	Deletes an existing machine catalog from the Citrix site.
.PARAMETER Name
	The name of the catalog to remove.
.EXAMPLE
	PS> ./Remove-CitrixCatalog.ps1 -Name "OldDesktops"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerCatalog -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed machine catalog '$Name'."
} catch {
	Write-Error $_
	exit 1
}