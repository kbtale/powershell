<#
.SYNOPSIS
	Citrix: Gets configuration log site
.DESCRIPTION
	Retrieves site-level configuration for configuration logging.
.EXAMPLE
	PS> ./Get-CitrixLogSite.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$site = Get-LogSite -ErrorAction Stop
	Write-Output $site
} catch {
	Write-Error $_
	exit 1
}