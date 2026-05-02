<#
.SYNOPSIS
	Citrix: Adds a scope
.DESCRIPTION
	Creates a new administrative scope in Citrix.
.PARAMETER Name
	The name of the new scope.
.PARAMETER Description
	The description of the scope (optional).
.EXAMPLE
	PS> ./Add-CitrixScope.ps1 -Name "London_Site" -Description "Resources in London"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $false)]
	[string]$Description
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	New-AdminScope -Name $Name -Description $Description -ErrorAction Stop
	Write-Output "Successfully created scope '$Name'."
} catch {
	Write-Error $_
	exit 1
}