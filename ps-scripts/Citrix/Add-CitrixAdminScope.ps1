<#
.SYNOPSIS
	Citrix: Adds an administrative scope
.DESCRIPTION
	Associates an administrative scope with an administrator in the Citrix site.
.PARAMETER AdministratorName
	The name of the administrator.
.PARAMETER ScopeName
	The name of the scope to add.
.EXAMPLE
	PS> ./Add-CitrixAdminScope.ps1 -AdministratorName "CONTOSO\Admin" -ScopeName "PrimarySite"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$AdministratorName,

	[Parameter(Mandatory = $true)]
	[string]$ScopeName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Add-AdminScope -Administrator $AdministratorName -Scope $ScopeName -ErrorAction Stop
	Write-Output "Successfully added scope '$ScopeName' to administrator '$AdministratorName'."
} catch {
	Write-Error $_
	exit 1
}