<#
.SYNOPSIS
	Citrix: Unlocks a machine
.DESCRIPTION
	Removes the administrative lock from a specific Citrix machine.
.PARAMETER MachineName
	The name of the machine to unlock.
.EXAMPLE
	PS> ./Unlock-CitrixMachine.ps1 -MachineName "CONTOSO\PC01"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Unlock-BrokerMachine -MachineName $MachineName -ErrorAction Stop
	Write-Output "Successfully unlocked machine '$MachineName'."
} catch {
	Write-Error $_
	exit 1
}