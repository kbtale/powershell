<#
.SYNOPSIS
	Citrix: Gets a report of permission groups
.DESCRIPTION
	Retrieves a summarized list of Citrix permission groups.
.EXAMPLE
	PS> ./Get-CitrixPermissionGroupReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$groups = Get-AdminPermissionGroup -ErrorAction Stop | Select-Object Name, Permissions
	Write-Output $groups
} catch {
	Write-Error $_
	exit 1
}