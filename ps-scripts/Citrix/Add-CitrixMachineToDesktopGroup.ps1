<#
.SYNOPSIS
	Citrix: Adds machines to a desktop group
.DESCRIPTION
	Adds one or more machines to a specified Citrix desktop group.
.PARAMETER MachineName
	The name(s) of the machine(s) to add.
.PARAMETER DesktopGroupName
	The name of the destination desktop group.
.EXAMPLE
	PS> ./Add-CitrixMachineToDesktopGroup.ps1 -MachineName "CONTOSO\PC01" -DesktopGroupName "Sales_Desktops"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string[]]$MachineName,

	[Parameter(Mandatory = $true)]
	[string]$DesktopGroupName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	foreach ($machine in $MachineName) {
		Add-BrokerMachine -MachineName $machine -DesktopGroup $DesktopGroupName -ErrorAction Stop
	}
	Write-Output "Successfully added machines to desktop group '$DesktopGroupName'."
} catch {
	Write-Error $_
	exit 1
}