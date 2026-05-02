<#
.SYNOPSIS
	Citrix: Gets access policy rule report
.DESCRIPTION
	Retrieves a summarized report of all access policy rules in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixAccessPolicyRuleReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerAccessPolicyRule -ErrorAction Stop | Select-Object Name, Enabled, DesktopGroupUid, AllowedUsers
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}