<#
.SYNOPSIS
	Citrix: Gets license usage details
.DESCRIPTION
	Retrieves detailed usage statistics for the licenses on the server.
.EXAMPLE
	PS> ./Get-CitrixLicenseUsageDetail.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$details = Get-LicUsageDetails -ErrorAction Stop
	Write-Output $details
} catch {
	Write-Error $_
	exit 1
}