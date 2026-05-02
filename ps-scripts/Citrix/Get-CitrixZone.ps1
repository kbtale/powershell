<#
.SYNOPSIS
	Citrix: Gets zones
.DESCRIPTION
	Retrieves a list of all zones in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixZone.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$zones = Get-BrokerZone -ErrorAction Stop
	Write-Output $zones
} catch {
	Write-Error $_
	exit 1
}