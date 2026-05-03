<#
.SYNOPSIS
	Citrix: Gets configuration log service instance
.DESCRIPTION
	Retrieves instances of the configuration logging service.
.EXAMPLE
	PS> ./Get-CitrixLogServiceInstance.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$instances = Get-LogServiceInstance -ErrorAction Stop
	Write-Output $instances
} catch {
	Write-Error $_
	exit 1
}