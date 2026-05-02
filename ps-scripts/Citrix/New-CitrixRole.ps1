<#
.SYNOPSIS
	Citrix: Creates a new role
.DESCRIPTION
	Creates a new administrative role in the Citrix site.
.PARAMETER Name
	The name of the role.
.PARAMETER Description
	The description of the role (optional).
.EXAMPLE
	PS> ./New-CitrixRole.ps1 -Name "Level1_Support" -Description "Basic troubleshooting rights"
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
	New-AdminRole -Name $Name -Description $Description -ErrorAction Stop
	Write-Output "Successfully created role '$Name'."
} catch {
	Write-Error $_
	exit 1
}