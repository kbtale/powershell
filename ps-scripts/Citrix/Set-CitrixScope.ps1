<#
.SYNOPSIS
	Citrix: Updates a scope
.DESCRIPTION
	Updates the description or properties of an existing Citrix administrative scope.
.PARAMETER Name
	The name of the scope.
.PARAMETER Description
	The new description for the scope.
.EXAMPLE
	PS> ./Set-CitrixScope.ps1 -Name "Finance_Scope" -Description "Resources for Finance Dept"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$Description
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Set-AdminScope -Name $Name -Description $Description -ErrorAction Stop
	Write-Output "Successfully updated scope '$Name'."
} catch {
	Write-Error $_
	exit 1
}