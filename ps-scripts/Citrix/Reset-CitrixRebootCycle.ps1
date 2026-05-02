<#
.SYNOPSIS
	Citrix: Resets a reboot cycle
.DESCRIPTION
	Restarts a reboot cycle for a Citrix desktop group.
.PARAMETER DesktopGroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./Reset-CitrixRebootCycle.ps1 -DesktopGroupName "SalesPool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$DesktopGroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Reset-BrokerRebootCycle -DesktopGroupName $DesktopGroupName -ErrorAction Stop
	Write-Output "Successfully reset reboot cycle for '$DesktopGroupName'."
} catch {
	Write-Error $_
	exit 1
}