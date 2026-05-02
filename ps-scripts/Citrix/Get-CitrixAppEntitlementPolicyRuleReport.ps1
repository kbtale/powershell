<#
.SYNOPSIS
	Citrix: Gets a report of application entitlement policy rules
.DESCRIPTION
	Retrieves a summarized list of all application entitlement policy rules in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixAppEntitlementPolicyRuleReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$rules = Get-BrokerAppEntitlementPolicyRule -ErrorAction Stop | Select-Object Name, Enabled, DesktopGroupName, IncludedUsers
	Write-Output $rules
} catch {
	Write-Error $_
	exit 1
}