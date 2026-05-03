<#
.SYNOPSIS
	Citrix: Updates an administrator role
.DESCRIPTION
	Updates the description or properties of an existing Citrix administrator role.
.PARAMETER Name
	The name of the role.
.PARAMETER Description
	The new description for the role.
.EXAMPLE
	PS> ./Set-CitrixRole.ps1 -Name "HelpDesk" -Description "Updated description for HelpDesk role"
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
	Set-AdminRole -Name $Name -Description $Description -ErrorAction Stop
	Write-Output "Successfully updated role '$Name'."
} catch {
	Write-Error $_
	exit 1
}