<#
.SYNOPSIS
	Citrix: Gets application entitlement policy rule metadata
.DESCRIPTION
	Retrieves metadata associated with a specific Citrix application entitlement policy rule.
.PARAMETER Name
	The name of the policy rule.
.EXAMPLE
	PS> ./Get-CitrixAppEntitlementPolicyRuleMetadata.ps1 -Name "FinanceRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerAppEntitlementPolicyRuleMetadata -Name $Name -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}