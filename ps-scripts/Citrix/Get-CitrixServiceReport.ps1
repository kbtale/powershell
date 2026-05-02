<#
.SYNOPSIS
	Citrix: Gets service report
.DESCRIPTION
	Retrieves a summarized report of all Citrix services and their status.
.EXAMPLE
	PS> ./Get-CitrixServiceReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	$report = Get-ConfigServiceInstance -ErrorAction Stop | Select-Object ServiceType, ServiceGroupUid, Address
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}