<#
.SYNOPSIS
	Citrix: Sets application entitlement policy rule metadata
.DESCRIPTION
	Updates or adds metadata associated with an application entitlement policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixAppEntitlementPolicyRuleMetadata.ps1 -Name "FinanceRule" -Map @{ 'Org' = 'FIN' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerAppEntitlementPolicyRuleMetadata -Name $Name -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}