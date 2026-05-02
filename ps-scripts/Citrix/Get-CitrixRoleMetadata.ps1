<#
.SYNOPSIS
	Citrix: Gets role metadata
.DESCRIPTION
	Retrieves metadata associated with a Citrix administrator role.
.PARAMETER RoleName
	The name of the role.
.EXAMPLE
	PS> ./Get-CitrixRoleMetadata.ps1 -RoleName "Full Administrator"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$RoleName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	$metadata = Get-AdminRoleMetadata -Role $RoleName -ErrorAction Stop
	Write-Output $metadata
} catch {
	Write-Error $_
	exit 1
}