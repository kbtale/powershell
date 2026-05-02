<#
.SYNOPSIS
	Citrix: Removes a controller from the site
.DESCRIPTION
	Unregisters a Delivery Controller from the Citrix site.
.PARAMETER ControllerName
	The name of the controller to remove.
.EXAMPLE
	PS> ./Remove-CitrixController.ps1 -ControllerName "CTX02.contoso.com"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ControllerName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerController -Name $ControllerName -ErrorAction Stop
	Write-Output "Successfully removed controller '$ControllerName'."
} catch {
	Write-Error $_
	exit 1
}