<#
.SYNOPSIS
	Citrix: Gets effective rights
.DESCRIPTION
	Retrieves the effective rights of a Citrix administrator across all roles and scopes.
.PARAMETER AdministratorName
	The name of the administrator.
.EXAMPLE
	PS> ./Get-CitrixEffectiveRight.ps1 -AdministratorName "CONTOSO\User1"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$AdministratorName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$rights = Get-AdminEffectiveRight -Administrator $AdministratorName -ErrorAction Stop
	Write-Output $rights
} catch {
	Write-Error $_
	exit 1
}