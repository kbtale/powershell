<#
.SYNOPSIS
	Citrix: Gets license SA renewal options
.DESCRIPTION
	Retrieves Subscription Advantage (SA) renewal options for installed licenses.
.EXAMPLE
	PS> ./Get-CitrixLicenseSARenewalOption.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$options = Get-LicSARenewalOptions -ErrorAction Stop
	Write-Output $options
} catch {
	Write-Error $_
	exit 1
}