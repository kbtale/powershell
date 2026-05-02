<#
.SYNOPSIS
	Citrix: Gets installed configuration log database version
.DESCRIPTION
	Retrieves the version of the database schema used for configuration logging.
.EXAMPLE
	PS> ./Get-CitrixLogInstalledDBVersion.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$version = Get-LogInstalledDBVersion -ErrorAction Stop
	Write-Output $version
} catch {
	Write-Error $_
	exit 1
}