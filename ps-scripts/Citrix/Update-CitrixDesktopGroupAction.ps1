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
	[ValidateSet('Reboot', 'EnableMaintenanceMode', 'DisableMaintenanceMode')]
	[string]$Action
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	switch ($Action) {
		'Reboot' {
			New-BrokerRebootCycle -DesktopGroupName $GroupName -ErrorAction Stop
			Write-Output "Reboot cycle started for desktop group '$GroupName'."
		}
		'EnableMaintenanceMode' {
			Set-BrokerDesktopGroup -Name $GroupName -InMaintenanceMode $true -ErrorAction Stop
			Write-Output "Maintenance mode enabled for desktop group '$GroupName'."
		}
		'DisableMaintenanceMode' {
			Set-BrokerDesktopGroup -Name $GroupName -InMaintenanceMode $false -ErrorAction Stop
			Write-Output "Maintenance mode disabled for desktop group '$GroupName'."
		}
	}
} catch {
	Write-Error $_
	exit 1
}