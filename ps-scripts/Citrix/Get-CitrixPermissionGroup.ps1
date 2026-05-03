<#
.SYNOPSIS
	Citrix: Gets permission groups
.DESCRIPTION
	Lists defined permission groups in Citrix.
.PARAMETER Name
	The name of the permission group (optional).
.EXAMPLE
	PS> ./Get-CitrixPermissionGroup.ps1
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

	$groups = Get-AdminPermissionGroup @cmdArgs
	Write-Output $groups
} catch {
	Write-Error $_
	exit 1
}