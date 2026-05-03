<#
.SYNOPSIS
	Citrix: Updates a license administrator
.DESCRIPTION
	Updates the role or properties of an existing Citrix license administrator.
.PARAMETER Name
	The name of the administrator.
.PARAMETER Role
	The new role to assign.
.EXAMPLE
	PS> ./Set-CitrixLicenseAdministrator.ps1 -Name "CONTOSO\LicenseAdmin" -Role "ReadOnly"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$Role
)

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	Set-LicAdministrator -Name $Name -Role $Role -ErrorAction Stop
	Write-Output "Successfully updated license administrator '$Name'."
} catch {
	Write-Error $_
	exit 1
}