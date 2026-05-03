<#
.SYNOPSIS
	Citrix: Gets configuration log low-level operations
.DESCRIPTION
	Retrieves detailed low-level operations from the configuration log.
.EXAMPLE
	PS> ./Get-CitrixLogLowLevelOperation.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$ops = Get-LogLowLevelOperation -ErrorAction Stop
	Write-Output $ops
} catch {
	Write-Error $_
	exit 1
}