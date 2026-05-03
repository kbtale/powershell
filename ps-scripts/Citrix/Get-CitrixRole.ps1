<#
.SYNOPSIS
	Citrix: Gets roles
.DESCRIPTION
	Lists all administrator roles defined in the Citrix site.
.PARAMETER Name
	The name of the role to filter by (optional).
.EXAMPLE
	PS> ./Get-CitrixRole.ps1
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

	$roles = Get-AdminRole @cmdArgs
	Write-Output $roles
} catch {
	Write-Error $_
	exit 1
}