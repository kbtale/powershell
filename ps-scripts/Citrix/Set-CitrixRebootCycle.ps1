<#
.SYNOPSIS
	Citrix: Updates a reboot cycle
.DESCRIPTION
	Updates the properties or timing of an active Citrix reboot cycle.
.PARAMETER DesktopGroupName
	The name of the desktop group.
.PARAMETER WarningDuration
	Duration of the warning message in minutes.
.EXAMPLE
	PS> ./Set-CitrixRebootCycle.ps1 -DesktopGroupName "SalesPool" -WarningDuration 15
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$DesktopGroupName,

	[Parameter(Mandatory = $true)]
	[int]$WarningDuration
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerRebootCycle -DesktopGroupName $DesktopGroupName -WarningDuration $WarningDuration -ErrorAction Stop
	Write-Output "Successfully updated reboot cycle for '$DesktopGroupName'."
} catch {
	Write-Error $_
	exit 1
}