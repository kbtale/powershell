<#
.SYNOPSIS
	Citrix: Gets a report of Citrix services
.DESCRIPTION
	Retrieves a summarized status report of all Citrix services.
.EXAMPLE
	PS> ./Get-CitrixServiceReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Configuration.Admin.V2 -ErrorAction Stop
	$services = Get-ConfigService -ErrorAction Stop | Select-Object ServiceType, ServiceInstanceId, Version
	Write-Output $services
} catch {
	Write-Error $_
	exit 1
}