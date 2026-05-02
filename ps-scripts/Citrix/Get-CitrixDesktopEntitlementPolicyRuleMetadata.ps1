<#
.SYNOPSIS
	Citrix: Gets desktop entitlement policy rule metadata
.DESCRIPTION
	Retrieves metadata associated with a specific desktop entitlement policy rule.
.PARAMETER Name
	The name of the policy rule.
.EXAMPLE
	PS> ./Get-CitrixDesktopEntitlementPolicyRuleMetadata.ps1 -Name "DevRule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerDesktopEntitlementPolicyRuleMetadata -Name $Name -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}