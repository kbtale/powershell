<#
.SYNOPSIS
	Citrix: Sets scope metadata
.DESCRIPTION
	Updates or adds metadata associated with a Citrix administrative scope.
.PARAMETER ScopeName
	The name of the scope.
.PARAMETER Map
	A hashtable of metadata key-value pairs.
.EXAMPLE
	PS> ./Set-CitrixScopeMetadata.ps1 -ScopeName "All" -Map @{ 'Status' = 'Active' }
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ScopeName,

	[Parameter(Mandatory = $true)]
	[hashtable]$Map
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Set-AdminScopeMetadata -Scope $ScopeName -Map $Map -ErrorAction Stop
	Write-Output "Successfully updated metadata for scope '$ScopeName'."
} catch {
	Write-Error $_
	exit 1
}