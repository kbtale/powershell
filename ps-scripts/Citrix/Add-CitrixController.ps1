<#
.SYNOPSIS
	Citrix: Adds a controller to the site
.DESCRIPTION
	Registers a new Delivery Controller in the Citrix site.
.PARAMETER ControllerName
	The FQDN of the controller to add.
.EXAMPLE
	PS> ./Add-CitrixController.ps1 -ControllerName "CTX02.contoso.com"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ControllerName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$controller = Add-BrokerController -Name $ControllerName -ErrorAction Stop
	Write-Output $controller
} catch {
	Write-Error $_
	exit 1
}