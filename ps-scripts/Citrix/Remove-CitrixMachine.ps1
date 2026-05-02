<#
.SYNOPSIS
	Citrix: Removes a machine
.DESCRIPTION
	Deletes a machine from the Citrix site configuration.
.PARAMETER MachineName
	The name of the machine to remove.
.EXAMPLE
	PS> ./Remove-CitrixMachine.ps1 -MachineName "CONTOSO\PC01"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Remove-BrokerMachine -MachineName $MachineName -Force -ErrorAction Stop
	Write-Output "Successfully removed machine '$MachineName' from Citrix site."
} catch {
	Write-Error $_
	exit 1
}