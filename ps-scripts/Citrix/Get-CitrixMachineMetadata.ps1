<#
.SYNOPSIS
	Citrix: Gets machine metadata
.DESCRIPTION
	Retrieves metadata associated with a specific machine in the Citrix site.
.PARAMETER MachineName
	The name of the machine.
.EXAMPLE
	PS> ./Get-CitrixMachineMetadata.ps1 -MachineName "CONTOSO\PC01"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$metadata = Get-BrokerMachineMetadata -MachineName $MachineName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}