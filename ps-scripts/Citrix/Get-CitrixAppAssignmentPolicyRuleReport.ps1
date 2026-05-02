<#
.SYNOPSIS
	Citrix: Gets application assignment policy rule report
.DESCRIPTION
	Retrieves a summarized report of all application assignment policy rules.
.EXAMPLE
	PS> ./Get-CitrixAppAssignmentPolicyRuleReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerAppAssignmentPolicyRule -ErrorAction Stop | Select-Object Name, Enabled, DesktopGroupUid
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}