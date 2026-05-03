<#
.SYNOPSIS
	Citrix: Gets a report of effective administrators
.DESCRIPTION
	Retrieves summarized effective rights for all administrators in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixAdminEffectiveAdministratorReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$admins = Get-AdminAdministrator -ErrorAction Stop
	$report = foreach ($a in $admins) {
		Get-AdminEffectiveAdministrator -Name $a.Name -ErrorAction SilentlyContinue | Select-Object Name, Roles, Scopes
	}
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}