<#
.SYNOPSIS
	Citrix: Gets reboot schedule report
.DESCRIPTION
	Retrieves a summarized report of all reboot schedules in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixRebootScheduleReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$report = Get-BrokerRebootSchedule -ErrorAction Stop | Select-Object Name, DesktopGroupName, Enabled, Frequency, StartTime
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}