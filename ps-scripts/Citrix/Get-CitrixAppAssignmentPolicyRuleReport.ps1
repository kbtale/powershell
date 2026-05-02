<#
.SYNOPSIS
	Citrix: Gets a report of application assignment policy rules
.DESCRIPTION
	Retrieves a summarized list of all application assignment policy rules in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixAppAssignmentPolicyRuleReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$rules = Get-BrokerAppAssignmentPolicyRule -ErrorAction Stop | Select-Object Name, Enabled, DesktopGroupName, IncludedUsers
	Write-Output $rules
} catch {
	Write-Error $_
	exit 1
}