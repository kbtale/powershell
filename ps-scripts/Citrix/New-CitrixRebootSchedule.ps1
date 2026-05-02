<#
.SYNOPSIS
	Citrix: Creates a new reboot schedule
.DESCRIPTION
	Creates a periodic reboot schedule for a Citrix desktop group.
.PARAMETER DesktopGroupName
	The name of the desktop group.
.PARAMETER Frequency
	The reboot frequency (Daily, Weekly).
.EXAMPLE
	PS> ./New-CitrixRebootSchedule.ps1 -DesktopGroupName "SalesPool" -Frequency Weekly
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$DesktopGroupName,

	[Parameter(Mandatory = $true)]
	[ValidateSet('Daily', 'Weekly')]
	[string]$Frequency
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$schedule = New-BrokerRebootSchedule -DesktopGroupName $DesktopGroupName -Frequency $Frequency -ErrorAction Stop
	Write-Output $schedule
} catch {
	Write-Error $_
	exit 1
}