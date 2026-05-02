<#
.SYNOPSIS
	Citrix: Gets site details
.DESCRIPTION
	Retrieves general information about the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixSite.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$site = Get-BrokerSite -ErrorAction Stop
	Write-Output $site
} catch {
	Write-Error $_
	exit 1
}