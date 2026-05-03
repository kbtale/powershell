<#
.SYNOPSIS
	Citrix: Gets configuration log database connection
.DESCRIPTION
	Retrieves the database connection string for the configuration logging service.
.EXAMPLE
	PS> ./Get-CitrixLogDBConnection.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$connection = Get-LogDBConnection -ErrorAction Stop
	Write-Output $connection
} catch {
	Write-Error $_
	exit 1
}