<#
.SYNOPSIS
	Citrix: Gets a report of permissions
.DESCRIPTION
	Retrieves a summarized list of available Citrix permissions.
.EXAMPLE
	PS> ./Get-CitrixPermissionReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$perms = Get-AdminPermission -ErrorAction Stop | Select-Object Name, Description
	Write-Output $perms
} catch {
	Write-Error $_
	exit 1
}