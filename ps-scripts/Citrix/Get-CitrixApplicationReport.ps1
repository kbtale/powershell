<#
.SYNOPSIS
	Citrix: Gets application report
.DESCRIPTION
	Retrieves a summarized report of all applications in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixApplicationReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerApplication -ErrorAction Stop | Select-Object Name, PublishedName, Enabled, ApplicationType
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}