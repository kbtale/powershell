<#
.SYNOPSIS
	Citrix: Gets a report of roles
.DESCRIPTION
	Retrieves a summarized list of Citrix administrator roles.
.EXAMPLE
	PS> ./Get-CitrixRoleReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$roles = Get-AdminRole -ErrorAction Stop | Select-Object Name, Description, BuiltIn
	Write-Output $roles
} catch {
	Write-Error $_
	exit 1
}