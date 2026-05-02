<#
.SYNOPSIS
	Citrix: Removes a reboot cycle
.DESCRIPTION
	Cancels or removes a reboot cycle record in the Citrix site.
.PARAMETER DesktopGroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./Remove-CitrixRebootCycle.ps1 -DesktopGroupName "SalesPool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$DesktopGroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerRebootCycle -DesktopGroupName $DesktopGroupName -ErrorAction Stop
	Write-Output "Successfully removed/cancelled reboot cycle for '$DesktopGroupName'."
} catch {
	Write-Error $_
	exit 1
}