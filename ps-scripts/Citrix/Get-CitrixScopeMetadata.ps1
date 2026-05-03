<#
.SYNOPSIS
	Citrix: Gets scope metadata
.DESCRIPTION
	Retrieves metadata associated with a Citrix administrative scope.
.PARAMETER ScopeName
	The name of the scope.
.EXAMPLE
	PS> ./Get-CitrixScopeMetadata.ps1 -ScopeName "All"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ScopeName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$metadata = Get-AdminScopeMetadata -Scope $ScopeName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}