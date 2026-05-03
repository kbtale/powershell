<#
.SYNOPSIS
	Citrix: Updates a reboot schedule
.DESCRIPTION
	Updates the configuration of an existing Citrix reboot schedule.
.PARAMETER Name
	The name of the reboot schedule.
.PARAMETER Enabled
	Whether the reboot schedule is enabled.
.EXAMPLE
	PS> ./Set-CitrixRebootSchedule.ps1 -Name "Weekly_Reboot" -Enabled $false
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerRebootSchedule -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated reboot schedule '$Name'."
} catch {
	Write-Error $_
	exit 1
}