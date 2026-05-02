<#
.SYNOPSIS
	Citrix: Gets scope report
.DESCRIPTION
	Retrieves a summarized report of all administrative scopes in the Citrix site.
.EXAMPLE
	PS> ./Get-CitrixScopeReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$report = Get-AdminScope -ErrorAction Stop | Select-Object Name, Description, IsBuiltIn
	Write-Output $report
} catch {
	Write-Error $_
	exit 1
}