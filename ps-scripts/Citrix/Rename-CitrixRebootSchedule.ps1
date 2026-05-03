<#
.SYNOPSIS
	Citrix: Renames a reboot schedule
.DESCRIPTION
	Changes the name of an existing Citrix reboot schedule.
.PARAMETER Name
	The current name of the schedule.
.PARAMETER NewName
	The new name for the schedule.
.EXAMPLE
	PS> ./Rename-CitrixRebootSchedule.ps1 -Name "Daily" -NewName "Daily_Reboot_Schedule"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$NewName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Rename-BrokerRebootSchedule -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed reboot schedule '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}