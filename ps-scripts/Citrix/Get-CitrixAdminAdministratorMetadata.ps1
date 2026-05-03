<#
.SYNOPSIS
	Citrix: Gets administrator metadata
.DESCRIPTION
	Retrieves metadata associated with a specific Citrix administrator.
.PARAMETER AdministratorName
	The name of the administrator.
.EXAMPLE
	PS> ./Get-CitrixAdminAdministratorMetadata.ps1 -AdministratorName "CONTOSO\Admin"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$AdministratorName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$metadata = Get-AdminAdministratorMetadata -Administrator $AdministratorName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}