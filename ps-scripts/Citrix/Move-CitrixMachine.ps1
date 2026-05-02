<#
.SYNOPSIS
	Citrix: Moves a machine
.DESCRIPTION
	Moves a Citrix machine to a different desktop group.
.PARAMETER MachineName
	The name of the machine.
.PARAMETER DestinationGroupName
	The name of the target desktop group.
.EXAMPLE
	PS> ./Move-CitrixMachine.ps1 -MachineName "CONTOSO\PC01" -DestinationGroupName "HR_Pool"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName,

	[Parameter(Mandatory = $true)]
	[string]$DestinationGroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerMachine -MachineName $MachineName -DesktopGroup $DestinationGroupName -ErrorAction Stop
	Write-Output "Successfully moved machine '$MachineName' to '$DestinationGroupName'."
} catch {
	Write-Error $_
	exit 1
}