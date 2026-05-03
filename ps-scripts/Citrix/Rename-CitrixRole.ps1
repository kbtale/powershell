<#
.SYNOPSIS
	Citrix: Renames an administrator role
.DESCRIPTION
	Changes the name of an existing Citrix administrator role.
.PARAMETER Name
	The current name of the role.
.PARAMETER NewName
	The new name for the role.
.EXAMPLE
	PS> ./Rename-CitrixRole.ps1 -Name "Level1" -NewName "Junior_Admin"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$NewName
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Rename-AdminRole -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed role '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}