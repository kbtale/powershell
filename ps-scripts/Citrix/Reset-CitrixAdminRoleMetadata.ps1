<#
.SYNOPSIS
	Citrix: Resets role metadata
.DESCRIPTION
	Resets metadata for a specific Citrix administrative role to its default state.
.PARAMETER RoleName
	The name of the role.
.EXAMPLE
	PS> ./Reset-CitrixAdminRoleMetadata.ps1 -RoleName "HelpDesk"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$RoleName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Set-AdminRoleMetadata -Role $RoleName -Map @{} -ErrorAction Stop
	Write-Output "Successfully reset metadata for role '$RoleName'."
} catch {
	Write-Error $_
	exit 1
}