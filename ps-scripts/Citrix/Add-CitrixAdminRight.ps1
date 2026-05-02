<#
.SYNOPSIS
	Citrix: Adds an administrative right
.DESCRIPTION
	Associates an administrative right with a role in the Citrix site.
.PARAMETER RoleName
	The name of the role.
.PARAMETER Right
	The right/permission to add.
.EXAMPLE
	PS> ./Add-CitrixAdminRight.ps1 -RoleName "HelpDesk" -Right "FullAccess"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$RoleName,

	[Parameter(Mandatory = $true)]
	[string]$Right
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Add-AdminRight -Role $RoleName -Right $Right -ErrorAction Stop
	Write-Output "Successfully added right '$Right' to role '$RoleName'."
} catch {
	Write-Error $_
	exit 1
}