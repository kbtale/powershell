<#
.SYNOPSIS
	Citrix: Invokes a machine command
.DESCRIPTION
	Triggers an administrative command (e.g. restart, power on) for a Citrix machine.
.PARAMETER MachineName
	The name of the machine.
.PARAMETER Action
	The action to perform (e.g. TurnOn, TurnOff, Restart).
.EXAMPLE
	PS> ./Invoke-CitrixMachineCommand.ps1 -MachineName "CONTOSO\PC01" -Action Restart
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName,

	[Parameter(Mandatory = $true)]
	[ValidateSet('TurnOn', 'TurnOff', 'Restart', 'Shutdown')]
	[string]$Action
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	New-BrokerMachineCommand -MachineName $MachineName -Category Power -Command $Action -ErrorAction Stop
	Write-Output "Successfully invoked '$Action' on machine '$MachineName'."
} catch {
	Write-Error $_
	exit 1
}