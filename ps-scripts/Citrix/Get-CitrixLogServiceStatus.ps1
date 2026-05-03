<#
.SYNOPSIS
	Citrix: Gets configuration log service status
.DESCRIPTION
	Retrieves the operational status of the configuration logging service.
.EXAMPLE
	PS> ./Get-CitrixLogServiceStatus.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$status = Get-LogServiceStatus -ErrorAction Stop
	Write-Output $status
} catch {
	Write-Error $_
	exit 1
}