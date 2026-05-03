<#
.SYNOPSIS
	Citrix: Creates a permission group
.DESCRIPTION
	Creates a new administrative permission group in Citrix.
.PARAMETER Name
	The name of the permission group.
.EXAMPLE
	PS> ./New-CitrixPermissionGroup.ps1 -Name "Custom_Admins"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	New-AdminPermissionGroup -Name $Name -ErrorAction Stop
	Write-Output "Successfully created permission group '$Name'."
} catch {
	Write-Error $_
	exit 1
}