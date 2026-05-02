<#
.SYNOPSIS
	Citrix: Gets configuration log service
.DESCRIPTION
	Retrieves configuration and status of the configuration logging service.
.EXAMPLE
	PS> ./Get-CitrixLogService.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$service = Get-LogService -ErrorAction Stop
	Write-Output $service
} catch {
	Write-Error $_
	exit 1
}