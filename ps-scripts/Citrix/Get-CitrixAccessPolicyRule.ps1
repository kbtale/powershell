<#
.SYNOPSIS
	Citrix: Gets access policy rules
.DESCRIPTION
	Retrieves access policy rules defined in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixAccessPolicyRule.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$rules = Get-BrokerAccessPolicyRule -ErrorAction Stop
	Write-Output $rules
} catch {
	Write-Error $_
	exit 1
}