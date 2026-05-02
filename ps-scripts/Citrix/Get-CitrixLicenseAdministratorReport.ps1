<#
.SYNOPSIS
	Citrix: Gets a report of license administrators
.DESCRIPTION
	Retrieves a summarized list of all license administrators in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixLicenseAdministratorReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$admins = Get-LicAdministrator -ErrorAction Stop | Select-Object Name, Role, Description
	Write-Output $admins
} catch {
	Write-Error $_
	exit 1
}