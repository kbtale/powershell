<#
.SYNOPSIS
	Citrix: Removes an entitlement policy rule
.DESCRIPTION
	Deletes an existing entitlement policy rule from the Citrix site.
.PARAMETER Name
	The name of the rule to remove.
.EXAMPLE
	PS> ./Remove-CitrixEntitlementPolicyRule.ps1 -Name "PoolEntitlement"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerEntitlementPolicyRule -Name $Name -ErrorAction Stop
	Write-Output "Successfully removed entitlement policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}