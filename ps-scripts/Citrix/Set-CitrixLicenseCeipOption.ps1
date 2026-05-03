<#
.SYNOPSIS
	Citrix: Sets license CEIP option
.DESCRIPTION
	Updates the Customer Experience Improvement Program (CEIP) setting for the license server.
.PARAMETER Enabled
	Whether to enable CEIP.
.EXAMPLE
	PS> ./Set-CitrixLicenseCeipOption.ps1 -Enabled $true
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	Set-LicCeipOption -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated CEIP option."
} catch {
	Write-Error $_
	exit 1
}