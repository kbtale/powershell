<#
.SYNOPSIS
	Citrix: Updates a machine
.DESCRIPTION
	Updates the properties or maintenance mode of a Citrix machine.
.PARAMETER MachineName
	The name of the machine.
.PARAMETER InMaintenanceMode
	Whether the machine should be in maintenance mode.
.EXAMPLE
	PS> ./Set-CitrixMachine.ps1 -MachineName "CONTOSO\PC01" -InMaintenanceMode $true
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName,

	[Parameter(Mandatory = $true)]
	[bool]$InMaintenanceMode
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerMachine -MachineName $MachineName -InMaintenanceMode $InMaintenanceMode -ErrorAction Stop
	Write-Output "Successfully updated maintenance mode for machine '$MachineName'."
} catch {
	Write-Error $_
	exit 1
}