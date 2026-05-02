<#
.SYNOPSIS
	Citrix: Gets role report
.DESCRIPTION
	Retrieves a summarized report of all administrative roles in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixRoleReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$report = Get-AdminRole -ErrorAction Stop | Select-Object Name, Description, IsBuiltIn
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}