<#
.SYNOPSIS
	Citrix: Resets configuration log data store
.DESCRIPTION
	Resets the configuration logging data store to its default state.
.EXAMPLE
	PS> ./Reset-CitrixLogDataStore.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	Reset-LogDataStore -ErrorAction Stop
	Write-Output "Successfully reset configuration log data store."
} catch {
	Write-Error $_
	exit 1
}