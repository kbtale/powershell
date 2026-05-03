<#
.SYNOPSIS
	Citrix: Creates a new license administrator
.DESCRIPTION
	Registers a new administrative user for the Citrix license server.
.PARAMETER Name
	The name of the user or group.
.PARAMETER Role
	The role to assign (e.g., Admin, ReadOnly).
.EXAMPLE
	PS> ./New-CitrixLicenseAdministrator.ps1 -Name "CONTOSO\LicenseAdmin" -Role "Admin"
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
	$admin = New-LicAdministrator -Name $Name -Role $Role -ErrorAction Stop
	Write-Output $admin
} catch {
	Write-Error $_
	exit 1
}