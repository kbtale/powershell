<#
.SYNOPSIS
	Citrix: Gets license server info
.DESCRIPTION
	Retrieves general information and status of the Citrix license server.
.EXAMPLE
	PS> ./Get-CitrixLicenseServerInfo.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$info = Get-LicServerInfo -ErrorAction Stop
	Write-Output $info
} catch {
	Write-Error $_
	exit 1
}