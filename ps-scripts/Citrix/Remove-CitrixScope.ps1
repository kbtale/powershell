<#
.SYNOPSIS
	Citrix: Removes a scope
.DESCRIPTION
	Deletes an existing administrative scope from the Citrix site.
.PARAMETER Name
	The name of the scope to remove.
.EXAMPLE
	PS> ./Remove-CitrixScope.ps1 -Name "Old_Site_Scope"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Remove-AdminScope -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed scope '$Name'."
} catch {
	Write-Error $_
	exit 1
}