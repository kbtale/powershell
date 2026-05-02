<#
.SYNOPSIS
	Citrix: Updates an application entitlement policy rule
.DESCRIPTION
	Updates the properties or status of an existing application entitlement policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER Enabled
	Whether the policy rule is enabled.
.EXAMPLE
	PS> ./Set-CitrixAppEntitlementPolicyRule.ps1 -Name "FinanceRule" -Enabled $true
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerAppEntitlementPolicyRule -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated application entitlement policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}