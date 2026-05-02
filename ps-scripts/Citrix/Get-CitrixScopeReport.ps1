<#
.SYNOPSIS
	Citrix: Gets a report of scopes
.DESCRIPTION
	Retrieves a summarized list of Citrix administrative scopes.
.EXAMPLE
	PS> ./Get-CitrixScopeReport.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$scopes = Get-AdminScope -ErrorAction Stop | Select-Object Name, Description, BuiltIn
	Write-Output $scopes
} catch {
	Write-Error $_
	exit 1
}