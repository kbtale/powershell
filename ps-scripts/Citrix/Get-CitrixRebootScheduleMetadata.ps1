<#
.SYNOPSIS
	Citrix: Gets reboot schedule metadata
.DESCRIPTION
	Retrieves metadata associated with a specific Citrix reboot schedule.
.PARAMETER Name
	The name of the reboot schedule.
.EXAMPLE
	PS> ./Get-CitrixRebootScheduleMetadata.ps1 -Name "Weekly_Reboot"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerRebootScheduleMetadata -Name $Name -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}