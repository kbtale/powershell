<#
.SYNOPSIS
	Citrix: Tests license server
.DESCRIPTION
	Validates the connectivity and status of the Citrix license server.
.EXAMPLE
	PS> ./Test-CitrixLicenseServer.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$status = Test-LicServer -ErrorAction Stop
	Write-Output $status
} catch {
	Write-Error $_
	exit 1
}