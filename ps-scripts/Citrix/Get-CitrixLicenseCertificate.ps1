<#
.SYNOPSIS
	Citrix: Gets license certificate
.DESCRIPTION
	Retrieves information about the certificates installed on the license server.
.EXAMPLE
	PS> ./Get-CitrixLicenseCertificate.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$certs = Get-LicCertificate -ErrorAction Stop
	Write-Output $certs
} catch {
	Write-Error $_
	exit 1
}