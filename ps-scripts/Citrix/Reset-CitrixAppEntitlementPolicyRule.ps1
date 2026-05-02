<#
.SYNOPSIS
	Citrix: Resets an application entitlement policy rule
.DESCRIPTION
	Resets the properties of a Citrix application entitlement policy rule to their default values.
.PARAMETER Name
	The name of the policy rule.
.EXAMPLE
	PS> ./Reset-CitrixAppEntitlementPolicyRule.ps1 -Name "FinanceRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerAppEntitlementPolicyRule -Name $Name -Enabled $true -ErrorAction Stop
	Write-Output "Successfully reset application entitlement policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}