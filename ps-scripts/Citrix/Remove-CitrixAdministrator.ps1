<#
.SYNOPSIS
	Citrix: Removes an administrator
.DESCRIPTION
	Deletes a registered administrator from the Citrix site.
.PARAMETER Name
	The name of the administrator to remove.
.EXAMPLE
	PS> ./Remove-CitrixAdministrator.ps1 -Name "CONTOSO\FormerEmployee"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Remove-AdminAdministrator -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed administrator '$Name'."
} catch {
	Write-Error $_
	exit 1
}