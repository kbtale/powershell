<#
.SYNOPSIS
	Citrix: Gets application entitlement policy rule report
.DESCRIPTION
	Retrieves a summarized report of all application entitlement policy rules.
.EXAMPLE
	PS> ./Get-CitrixAppEntitlementPolicyRuleReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerAppEntitlementPolicyRule -ErrorAction Stop | Select-Object Name, Enabled, DesktopGroupUid
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}