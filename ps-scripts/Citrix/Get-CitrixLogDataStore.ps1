<#
.SYNOPSIS
	Citrix: Gets configuration log data store
.DESCRIPTION
	Retrieves information about the data store used for configuration logging.
.EXAMPLE
	PS> ./Get-CitrixLogDataStore.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	$store = Get-LogDataStore -ErrorAction Stop
	Write-Output $store
} catch {
	Write-Error $_
	exit 1
}