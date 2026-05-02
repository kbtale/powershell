<#
.SYNOPSIS
	Citrix: Gets Citrix application groups
.DESCRIPTION
	Lists application groups defined in the Citrix site.
.PARAMETER Name
	The name of the application group (optional).
.EXAMPLE
	PS> ./Get-CitrixApplicationGroup.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$groups = Get-BrokerApplicationGroup @cmdArgs
	Write-Output $groups
} catch {
	Write-Error $_
	exit 1
}