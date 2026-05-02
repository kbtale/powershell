<#
.SYNOPSIS
	Citrix: Removes a license administrator
.DESCRIPTION
	Deletes an administrative user from the Citrix license server.
.PARAMETER Name
	The name of the administrator to remove.
.EXAMPLE
	PS> ./Remove-CitrixLicenseAdministrator.ps1 -Name "CONTOSO\LicenseAdmin"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	Remove-LicAdministrator -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed license administrator '$Name'."
} catch {
	Write-Error $_
	exit 1
}