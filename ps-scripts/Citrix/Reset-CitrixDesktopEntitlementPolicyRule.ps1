<#
.SYNOPSIS
	Citrix: Resets a desktop entitlement policy rule
.DESCRIPTION
	Resets the properties of a Citrix desktop entitlement policy rule to their default values.
.PARAMETER Name
	The name of the policy rule.
.EXAMPLE
	PS> ./Reset-CitrixDesktopEntitlementPolicyRule.ps1 -Name "DevRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerDesktopEntitlementPolicyRule -Name $Name -Enabled $true -ErrorAction Stop
	Write-Output "Successfully reset desktop entitlement policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}