<#
.SYNOPSIS
	Citrix: Updates an administrator
.DESCRIPTION
	Updates the properties or status of an existing Citrix administrator.
.PARAMETER Name
	The name of the administrator.
.PARAMETER Enabled
	Whether the administrator account is enabled.
.EXAMPLE
	PS> ./Set-CitrixAdministrator.ps1 -Name "CONTOSO\Admin1" -Enabled $false
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.DelegatedAdmin.Admin.V1 -ErrorAction Stop
	Set-AdminAdministrator -Name $Name -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated administrator '$Name'."
} catch {
	Write-Error $_
	exit 1
}