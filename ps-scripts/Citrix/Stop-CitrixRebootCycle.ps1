<#
.SYNOPSIS
	Citrix: Stops a reboot cycle
.DESCRIPTION
	Immediately halts an active reboot cycle for a Citrix desktop group.
.PARAMETER DesktopGroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./Stop-CitrixRebootCycle.ps1 -DesktopGroupName "SalesPool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$DesktopGroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Stop-BrokerRebootCycle -DesktopGroupName $DesktopGroupName -ErrorAction Stop
	Write-Output "Successfully stopped reboot cycle for '$DesktopGroupName'."
} catch {
	Write-Error $_
	exit 1
}