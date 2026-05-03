<#
.SYNOPSIS
	Citrix: Gets permissions
.DESCRIPTION
	Lists all available permissions in the Citrix site.
.PARAMETER Name
	The name of the permission (optional).
.EXAMPLE
	PS> ./Get-CitrixPermission.ps1
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

	$permissions = Get-AdminPermission @cmdArgs
	Write-Output $permissions
} catch {
	Write-Error $_
	exit 1
}