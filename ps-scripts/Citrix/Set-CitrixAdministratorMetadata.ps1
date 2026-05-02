<#
.SYNOPSIS
	Citrix: Sets administrator metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix administrator.
.PARAMETER AdministratorName
	The name of the administrator.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixAdministratorMetadata.ps1 -AdministratorName "CONTOSO\Admin" -Map @{ 'Dept' = 'IT' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$AdministratorName,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Set-AdminAdministratorMetadata -Administrator $AdministratorName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for administrator '$AdministratorName'."
} catch {
	Write-Error $_
	exit 1
}