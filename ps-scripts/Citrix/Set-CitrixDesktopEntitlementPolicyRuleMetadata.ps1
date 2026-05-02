<#
.SYNOPSIS
	Citrix: Sets desktop entitlement policy rule metadata
.DESCRIPTION
	Updates or adds metadata associated with a desktop entitlement policy rule.
.PARAMETER Name
	The name of the policy rule.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixDesktopEntitlementPolicyRuleMetadata.ps1 -Name "DevRule" -Map @{ 'Owner' = 'DevOps' }
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
	Set-BrokerDesktopEntitlementPolicyRuleMetadata -Name $Name -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for policy rule '$Name'."
} catch {
	Write-Error $_
	exit 1
}