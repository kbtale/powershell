<#
.SYNOPSIS
	Citrix: Adds a right to an administrator
.DESCRIPTION
	Assigns a role and scope (a "right") to a Citrix administrator.
.PARAMETER AdministratorName
	The name of the administrator (e.g. DOMAIN\User).
	[Parameter(Mandatory = $true)]
	[string]$RoleName,
	[Parameter(Mandatory = $true)]
	[string]$ScopeName
.EXAMPLE
	PS> ./Add-CitrixRight.ps1 -AdministratorName "CONTOSO\Admin" -RoleName "Full Administrator" -ScopeName "All"
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
	Add-AdminRight -Administrator $AdministratorName -Role $RoleName -Scope $ScopeName -ErrorAction Stop
	Write-Output "Successfully added right to administrator '$AdministratorName'."
} catch {
	Write-Error $_
	exit 1
}