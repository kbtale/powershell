<#
.SYNOPSIS
	Citrix: Sets role metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix administrator role.
.PARAMETER RoleName
	The name of the role.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixRoleMetadata.ps1 -RoleName "HelpDesk" -Map @{ 'Level' = '1' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$RoleName,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Set-AdminRoleMetadata -Role $RoleName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for role '$RoleName'."
} catch {
	Write-Error $_
	exit 1
}