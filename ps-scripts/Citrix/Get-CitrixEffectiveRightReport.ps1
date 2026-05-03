<#
.SYNOPSIS
	Citrix: Gets a report of effective rights
.DESCRIPTION
	Retrieves a summary of effective rights across the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixEffectiveRightReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$rights = Get-AdminEffectiveRight -ErrorAction Stop | Select-Object RoleName, ScopeName, PermissionName
	Write-Output $rights
} catch {
	Write-Error $_
	exit 1
}