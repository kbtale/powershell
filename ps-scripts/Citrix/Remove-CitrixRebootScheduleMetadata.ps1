<#
.SYNOPSIS
	Citrix: Removes reboot schedule metadata
.DESCRIPTION
	Deletes metadata associated with a Citrix reboot schedule.
.PARAMETER Name
	The name of the reboot schedule.
.PARAMETER PropertyName
	The name of the metadata property to remove.
.EXAMPLE
	PS> ./Remove-CitrixRebootScheduleMetadata.ps1 -Name "Weekly" -PropertyName "Trigger"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$PropertyName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerRebootScheduleMetadata -Name $Name -Name $PropertyName -ErrorAction Stop
	Write-Output "Successfully removed metadata property '$PropertyName' from reboot schedule '$Name'."
} catch {
	Write-Error $_
	exit 1
}