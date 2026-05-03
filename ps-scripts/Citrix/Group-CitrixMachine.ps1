<#
.SYNOPSIS
	Citrix: Groups machines
.DESCRIPTION
	Associates machines with a specific Citrix desktop group.
.PARAMETER MachineName
	The name(s) of the machine(s).
.PARAMETER DesktopGroupName
	The name of the desktop group.
.EXAMPLE
	PS> ./Group-CitrixMachine.ps1 -MachineName "CONTOSO\PC01" -DesktopGroupName "SalesPool"
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
	foreach ($m in $MachineName) {
		Set-BrokerMachine -MachineName $m -DesktopGroup $DesktopGroupName -ErrorAction Stop
	}
	Write-Output "Successfully grouped machines to '$DesktopGroupName'."
} catch {
	Write-Error $_
	exit 1
}