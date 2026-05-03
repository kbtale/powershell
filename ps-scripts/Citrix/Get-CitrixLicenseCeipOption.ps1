<#
.SYNOPSIS
	Citrix: Gets license CEIP option
.DESCRIPTION
	Retrieves the current Customer Experience Improvement Program (CEIP) setting for the license server.
.EXAMPLE
	PS> ./Get-CitrixLicenseCeipOption.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$option = Get-LicCeipOption -ErrorAction Stop
	Write-Output $option
} catch {
	Write-Error $_
	exit 1
}