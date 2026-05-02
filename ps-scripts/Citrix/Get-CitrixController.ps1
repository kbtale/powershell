<#
.SYNOPSIS
	Citrix: Gets site controllers
.DESCRIPTION
	Retrieves a list of all Delivery Controllers in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixController.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$controllers = Get-BrokerController -ErrorAction Stop
	Write-Output $controllers
} catch {
	Write-Error $_
	exit 1
}