<#
.SYNOPSIS
	Citrix: Gets effective administrator details
.DESCRIPTION
	Retrieves the effective rights and permissions for a Citrix administrator.
.PARAMETER AdministratorName
	The name of the administrator.
.EXAMPLE
	PS> ./Get-CitrixEffectiveAdministrator.ps1 -AdministratorName "CONTOSO\User1"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$AdministratorName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$effAdmin = Get-AdminEffectiveAdministrator -Name $AdministratorName -ErrorAction Stop
	Write-Output $effAdmin
} catch {
	Write-Error $_
	exit 1
}