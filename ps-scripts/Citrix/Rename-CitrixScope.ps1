<#
.SYNOPSIS
	Citrix: Renames a scope
.DESCRIPTION
	Changes the name of an existing Citrix administrative scope.
.PARAMETER Name
	The current name of the scope.
.PARAMETER NewName
	The new name for the scope.
.EXAMPLE
	PS> ./Rename-CitrixScope.ps1 -Name "OldSite" -NewName "NewSite"
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
	Rename-AdminScope -Name $Name -NewName $NewName -ErrorAction Stop
	Write-Output "Successfully renamed scope '$Name' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}