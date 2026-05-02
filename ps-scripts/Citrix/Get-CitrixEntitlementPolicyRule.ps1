<#
.SYNOPSIS
	Citrix: Gets entitlement policy rules
.DESCRIPTION
	Retrieves entitlement policy rules defined in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixEntitlementPolicyRule.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$rules = Get-BrokerEntitlementPolicyRule -ErrorAction Stop
	Write-Output $rules
} catch {
	Write-Error $_
	exit 1
}