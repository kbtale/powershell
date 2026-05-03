<#
.SYNOPSIS
	Citrix: Gets scopes
.DESCRIPTION
	Lists administrative scopes defined in the Citrix site.
.PARAMETER Name
	The name of the scope to filter by (optional).
.EXAMPLE
	PS> ./Get-CitrixScope.ps1
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$scopes = Get-AdminScope @cmdArgs
	Write-Output $scopes
} catch {
	Write-Error $_
	exit 1
}