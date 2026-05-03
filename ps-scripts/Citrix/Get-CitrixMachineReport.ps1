<#
.SYNOPSIS
	Citrix: Gets machine report
.DESCRIPTION
	Retrieves a summarized report of all machines in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixMachineReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerMachine -ErrorAction Stop | Select-Object MachineName, CatalogName, DesktopGroupName, RegistrationState, PowerState
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}