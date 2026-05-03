<#
.SYNOPSIS
	Citrix: Gets application folder report
.DESCRIPTION
	Retrieves a summarized report of all application folders in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixApplicationFolderReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerAdminFolder -ErrorAction Stop | Where-Object { $_.ObjectTypes -contains 'Application' } | Select-Object Name, TotalApplicationsLimit
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}