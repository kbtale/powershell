<#
.SYNOPSIS
	Citrix: Gets machines
.DESCRIPTION
	Lists machines in the Citrix site.
.PARAMETER MachineName
	The name of the machine (optional).
.EXAMPLE
	PS> ./Get-CitrixMachine.ps1 -MachineName "CONTOSO\PC*"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$MachineName
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($MachineName) { $cmdArgs.Add('MachineName', $MachineName) }

	$machines = Get-BrokerMachine @cmdArgs
	Write-Output $machines
} catch {
	Write-Error $_
	exit 1
}