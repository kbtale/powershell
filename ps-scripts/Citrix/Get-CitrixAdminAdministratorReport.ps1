<#
.SYNOPSIS
	Citrix: Gets a report of Citrix administrators
.DESCRIPTION
	Retrieves a summarized list of all Citrix administrators.
.EXAMPLE
	PS> ./Get-CitrixAdminAdministratorReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$admins = Get-AdminAdministrator -ErrorAction Stop | Select-Object Name, Enabled, SID, IsBuiltIn
	Write-Output $admins
} catch {
	Write-Error $_
	exit 1
}