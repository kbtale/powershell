<#
.SYNOPSIS
	Citrix: Adds a permission to a role
.DESCRIPTION
	Adds a specific permission to a Citrix administrator role.
.PARAMETER RoleName
	The name of the role.
.PARAMETER Permission
	The permission to add.
.EXAMPLE
	PS> ./Add-CitrixPermission.ps1 -RoleName "HelpDesk" -Permission "DelegatedAdmin_Read"
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
	Add-AdminPermission -Role $RoleName -Permission $Permission -ErrorAction Stop
	Write-Output "Successfully added permission '$Permission' to role '$RoleName'."
} catch {
	Write-Error $_
	exit 1
}