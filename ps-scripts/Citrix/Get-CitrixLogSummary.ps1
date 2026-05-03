<#
.SYNOPSIS
	Citrix: Gets configuration log summary
.DESCRIPTION
	Retrieves a summary of configuration logging activity.
.EXAMPLE
	PS> ./Get-CitrixLogSummary.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$summary = Get-LogSummary -ErrorAction Stop
	Write-Output $summary
} catch {
	Write-Error $_
	exit 1
}