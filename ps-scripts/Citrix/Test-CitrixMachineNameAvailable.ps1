<#
.SYNOPSIS
	Citrix: Tests machine name availability
.DESCRIPTION
	Checks if a specific machine name is available for use in the Citrix site.
.PARAMETER MachineName
	The name of the machine to check.
.EXAMPLE
	PS> ./Test-CitrixMachineNameAvailable.ps1 -MachineName "CONTOSO\PC01"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$MachineName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$available = Test-BrokerMachineNameAvailable -MachineName $MachineName -ErrorAction Stop
	if ($available) {
		Write-Output "Machine name '$MachineName' is available."
	} else {
		Write-Warning "Machine name '$MachineName' is NOT available."
	}
} catch {
	Write-Error $_
	exit 1
}