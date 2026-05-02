<#
.SYNOPSIS
	Citrix: Resets administrator metadata
.DESCRIPTION
	Resets metadata for a specific Citrix administrator to its default state.
.PARAMETER AdministratorName
	The name of the administrator.
.EXAMPLE
	PS> ./Reset-CitrixAdminAdministratorMetadata.ps1 -AdministratorName "CONTOSO\Admin"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$AdministratorName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	# Resetting involves clearing metadata.
	Set-AdminAdministratorMetadata -Administrator $AdministratorName -Map @{} -ErrorAction Stop
	Write-Output "Successfully reset metadata for administrator '$AdministratorName'."
} catch {
	Write-Error $_
	exit 1
}