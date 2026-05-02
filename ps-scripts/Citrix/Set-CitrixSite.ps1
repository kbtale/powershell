<#
.SYNOPSIS
	Citrix: Updates site properties
.DESCRIPTION
	Modifies site-level properties in the Citrix environment.
.PARAMETER Name
	The new name for the Citrix site.
.EXAMPLE
	PS> ./Set-CitrixSite.ps1 -Name "PrimarySite"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerSite -Name $Name -ErrorAction Stop
	Write-Output "Successfully updated site properties."
} catch {
	Write-Error $_
	exit 1
}