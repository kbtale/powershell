<#
.SYNOPSIS
	Citrix: Gets assignment policy rules
.DESCRIPTION
	Retrieves assignment policy rules defined in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixAssignmentPolicyRule.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$rules = Get-BrokerAssignmentPolicyRule -ErrorAction Stop
	Write-Output $rules
} catch {
	Write-Error $_
	exit 1
}