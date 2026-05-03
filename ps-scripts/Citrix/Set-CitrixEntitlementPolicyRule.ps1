<#
.SYNOPSIS
	Citrix: Updates an entitlement policy rule
.DESCRIPTION
	Modifies an existing entitlement policy rule's properties.
.PARAMETER Name
	The name of the rule to update.
.PARAMETER Enabled
	Whether the rule is enabled.
.EXAMPLE
	PS> ./Set-CitrixEntitlementPolicyRule.ps1 -Name "PoolEntitlement" -Enabled $true
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
	Set-BrokerEntitlementPolicyRule -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated entitlement policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}