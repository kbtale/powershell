<#
.SYNOPSIS
	Citrix: Gets a report of application groups
.DESCRIPTION
	Retrieves a summarized list of all application groups in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixApplicationGroupReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$groups = Get-BrokerApplicationGroup -ErrorAction Stop | Select-Object Name, Enabled, SessionCount, ApplicationCount
	Write-Output $groups
} catch {
	Write-Error $_
	exit 1
}