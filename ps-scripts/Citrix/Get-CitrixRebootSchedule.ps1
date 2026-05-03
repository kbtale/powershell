<#
.SYNOPSIS
	Citrix: Gets reboot schedules
.DESCRIPTION
	Lists configured reboot schedules for Citrix desktop groups.
.PARAMETER Name
	The name of the reboot schedule (optional).
.EXAMPLE
	PS> ./Get-CitrixRebootSchedule.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$schedules = Get-BrokerRebootSchedule @cmdArgs
	Write-Output $schedules
} catch {
	Write-Error $_
	exit 1
}