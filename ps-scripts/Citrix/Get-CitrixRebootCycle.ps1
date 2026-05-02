<#
.SYNOPSIS
	Citrix: Gets reboot cycles
.DESCRIPTION
	Lists active and completed reboot cycles for Citrix desktop groups.
.PARAMETER DesktopGroupName
	The name of the desktop group (optional).
.EXAMPLE
	PS> ./Get-CitrixRebootCycle.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$DesktopGroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($DesktopGroupName) { $cmdArgs.Add('DesktopGroupName', $DesktopGroupName) }

	$cycles = Get-BrokerRebootCycle @cmdArgs
	Write-Output $cycles
} catch {
	Write-Error $_
	exit 1
}