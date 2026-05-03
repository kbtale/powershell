<#
.SYNOPSIS
	Citrix: Gets a report of administrators
.DESCRIPTION
	Retrieves a summarized list of Citrix administrators.
.EXAMPLE
	PS> ./Get-CitrixAdministratorReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$admins = Get-AdminAdministrator -ErrorAction Stop | Select-Object Name, Enabled, Roles, Scopes
	Write-Output $admins
} catch {
	Write-Error $_
	exit 1
}