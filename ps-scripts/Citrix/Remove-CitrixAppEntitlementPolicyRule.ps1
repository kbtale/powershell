<#
.SYNOPSIS
	Citrix: Removes an application entitlement policy rule
.DESCRIPTION
	Deletes an existing application entitlement policy rule from the Citrix site.
.PARAMETER Name
	The name of the policy rule to remove.
.EXAMPLE
	PS> ./Remove-CitrixAppEntitlementPolicyRule.ps1 -Name "Finance_Entitlement"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerAppEntitlementPolicyRule -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed application entitlement policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}