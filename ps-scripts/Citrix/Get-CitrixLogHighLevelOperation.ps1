<#
.SYNOPSIS
	Citrix: Gets configuration log high-level operations
.DESCRIPTION
	Retrieves a list of high-level administrative operations from the configuration log.
.EXAMPLE
	PS> ./Get-CitrixLogHighLevelOperation.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$ops = Get-LogHighLevelOperation -ErrorAction Stop
	Write-Output $ops
} catch {
	Write-Error $_
	exit 1
}