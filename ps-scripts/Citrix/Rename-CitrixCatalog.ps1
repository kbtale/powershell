<#
.SYNOPSIS
	Citrix: Renames a machine catalog
.DESCRIPTION
	Changes the name of an existing Citrix machine catalog.
.PARAMETER Name
	The current name of the catalog.
.PARAMETER NewName
	The new name for the catalog.
.EXAMPLE
	PS> ./Rename-CitrixCatalog.ps1 -Name "VDI_Random" -NewName "VDI_Pool_A"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$NewName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Rename-BrokerCatalog -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed machine catalog '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}