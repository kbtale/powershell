<#
.SYNOPSIS
	Citrix: Sets reboot schedule metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix reboot schedule.
.PARAMETER Name
	The name of the reboot schedule.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixRebootScheduleMetadata.ps1 -Name "Weekly_Reboot" -Map @{ 'Cycle' = 'A' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerRebootScheduleMetadata -Name $Name -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for reboot schedule '$Name'."
} catch {
	Write-Error $_
	exit 1
}