<#
.SYNOPSIS
	Citrix: Gets license localized names
.DESCRIPTION
	Retrieves the localized names for products registered on the license server.
.EXAMPLE
	PS> ./Get-CitrixLicenseLocalizedName.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$names = Get-LicLocalizedNames -ErrorAction Stop
	Write-Output $names
} catch {
	Write-Error $_
	exit 1
}