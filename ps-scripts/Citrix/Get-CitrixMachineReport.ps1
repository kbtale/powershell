<#
.SYNOPSIS
	Citrix: Gets a report of machines
.DESCRIPTION
	Retrieves a summarized list of machines in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixMachineReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$machines = Get-BrokerMachine -ErrorAction Stop | Select-Object MachineName, DesktopGroupName, RegistrationState, PowerState, InMaintenanceMode
	Write-Output $machines
} catch {
	Write-Error $_
	exit 1
}