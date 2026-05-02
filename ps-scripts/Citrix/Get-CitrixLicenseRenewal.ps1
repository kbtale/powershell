<#
.SYNOPSIS
	Citrix: Gets license renewals
.DESCRIPTION
	Retrieves information about available or pending license renewals.
.EXAMPLE
	PS> ./Get-CitrixLicenseRenewal.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$renewals = Get-LicRenewals -ErrorAction Stop
	Write-Output $renewals
} catch {
	Write-Error $_
	exit 1
}