<#
.SYNOPSIS
	Citrix: Removes machine catalog metadata
.DESCRIPTION
	Deletes metadata associated with a Citrix machine catalog.
.PARAMETER Name
	The name of the catalog.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixCatalogMetadata.ps1 -Name "VDI_Pool" -PropertyName "BatchID"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerCatalogMetadata -Name $Name -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from catalog '$Name'."
} catch {
	Write-Error $_
	exit 1
}