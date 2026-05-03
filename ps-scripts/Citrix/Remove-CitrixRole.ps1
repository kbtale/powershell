<#
.SYNOPSIS
	Citrix: Removes an administrator role
.DESCRIPTION
	Deletes an existing administrator role from the Citrix site.
.PARAMETER Name
	The name of the role to remove.
.EXAMPLE
	PS> ./Remove-CitrixRole.ps1 -Name "Custom_Role"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Remove-AdminRole -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed role '$Name'."
} catch {
	Write-Error $_
	exit 1
}