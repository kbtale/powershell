<#
.SYNOPSIS
	Citrix: Removes a right from an administrator
.DESCRIPTION
	Removes a role and scope assignment (a "right") from a Citrix administrator.
.PARAMETER AdministratorName
	The name of the administrator.
.PARAMETER RoleName
	The name of the role.
.PARAMETER ScopeName
	The name of the scope.
.EXAMPLE
	PS> ./Remove-CitrixRight.ps1 -AdministratorName "CONTOSO\Admin" -RoleName "Full Administrator" -ScopeName "All"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$AdministratorName,

	[Parameter(Mandatory = $true)]
	[string]$RoleName,

	[Parameter(Mandatory = $true)]
	[string]$ScopeName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Remove-AdminRight -Administrator $AdministratorName -Role $RoleName -Scope $ScopeName -ErrorAction Stop
	Write-Output "Successfully removed right from administrator '$AdministratorName'."
} catch {
	Write-Error $_
	exit 1
}