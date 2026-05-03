<#
.SYNOPSIS
	Citrix: Gets license configuration usage samples
.DESCRIPTION
	Retrieves license configuration usage samples for analysis.
.EXAMPLE
	PS> ./Get-CitrixLicenseConfigUsageSamples.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$samples = Get-LicConfigUsageSamples -ErrorAction Stop
	Write-Output $samples
} catch {
	Write-Error $_
	exit 1
}