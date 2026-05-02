<#
.SYNOPSIS
	Citrix: Creates a new machine catalog
.DESCRIPTION
	Creates a new machine catalog in the Citrix site.
.PARAMETER Name
	The name of the machine catalog.
.PARAMETER AllocationType
	The allocation type (Static, Random).
.EXAMPLE
	PS> ./New-CitrixCatalog.ps1 -Name "VDI_Desktops" -AllocationType Random
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[ValidateSet('Static', 'Random')]
	[string]$AllocationType
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$catalog = New-BrokerCatalog -Name $Name -AllocationType $AllocationType -ErrorAction Stop
	Write-Output $catalog
} catch {
	Write-Error $_
	exit 1
}