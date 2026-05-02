<#
.SYNOPSIS
	Citrix: Adds a machine to a catalog
.DESCRIPTION
	Adds a new machine to an existing Citrix machine catalog.
.PARAMETER MachineName
	The name of the machine to add (e.g. DOMAIN\Machine$).
.PARAMETER CatalogName
	The name of the machine catalog.
.EXAMPLE
	PS> ./Add-CitrixMachine.ps1 -MachineName "CONTOSO\Workstation01" -CatalogName "VDI_Catalog"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName,

	[Parameter(Mandatory = $true)]
	[string]$CatalogName
)

try {
	# Note: Citrix cmdlets usually require the Citrix.Broker.Admin.V2 module or similar
	if (-not (Get-Module -ListAvailable Citrix.Broker.Admin.V2)) {
		throw "Citrix Broker PowerShell module not found."
	}
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	New-BrokerMachine -MachineName $MachineName -DesktopGroup $CatalogName -ErrorAction Stop
	Write-Output "Successfully added machine '$MachineName' to catalog '$CatalogName'."
} catch {
	Write-Error $_
	exit 1
}