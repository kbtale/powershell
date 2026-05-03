<#
.SYNOPSIS
	Citrix: Removes a reboot schedule
.DESCRIPTION
	Deletes a configured reboot schedule from the Citrix site.
.PARAMETER Name
	The name of the reboot schedule.
.EXAMPLE
	PS> ./Remove-CitrixRebootSchedule.ps1 -Name "Weekly_Reboot"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerRebootSchedule -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed reboot schedule '$Name'."
} catch {
	Write-Error $_
	exit 1
}