<#
.SYNOPSIS
	Citrix: Removes a permission from a role
.DESCRIPTION
	Removes a specific permission from a Citrix administrative role.
.PARAMETER RoleName
	The name of the role.
.PARAMETER Permission
	The permission to remove.
.EXAMPLE
	PS> ./Remove-CitrixPermission.ps1 -RoleName "HelpDesk" -Permission "DelegatedAdmin_Read"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$RoleName,

	[Parameter(Mandatory = $true)]
	[string]$Permission
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Remove-AdminPermission -Role $RoleName -Permission $Permission -ErrorAction Stop
	Write-Output "Successfully removed permission '$Permission' from role '$RoleName'."
} catch {
	Write-Error $_
	exit 1
}