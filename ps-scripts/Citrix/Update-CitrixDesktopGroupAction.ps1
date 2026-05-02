<#
.SYNOPSIS
	Citrix: Updates desktop group action
.DESCRIPTION
	Updates the administrative action configuration for a Citrix desktop group.
.PARAMETER GroupName
	The name of the desktop group.
.PARAMETER Action
	The action to update.
.EXAMPLE
	PS> ./Update-CitrixDesktopGroupAction.ps1 -GroupName "SalesPool" -Action "Reboot"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$GroupName,

	[Parameter(Mandatory = $true)]
	[string]$Action
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Update-BrokerDesktopGroup -Name $GroupName -ErrorAction Stop
	Write-Output "Update action triggered for desktop group '$GroupName'."
} catch {
	Write-Error $_
	exit 1
}