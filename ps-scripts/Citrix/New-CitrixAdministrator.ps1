<#
.SYNOPSIS
	Citrix: Creates a new administrator
.DESCRIPTION
	Registers a new administrator in the Citrix site.
.PARAMETER Name
	The name of the user or group (e.g. DOMAIN\User).
.EXAMPLE
	PS> ./New-CitrixAdministrator.ps1 -Name "CONTOSO\IT_Staff"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	New-AdminAdministrator -Name $Name -ErrorAction Stop
	Write-Output "Successfully created Citrix administrator '$Name'."
} catch {
	Write-Error $_
	exit 1
}