<#
.SYNOPSIS
	Citrix: Sets license SA renewal options
.DESCRIPTION
	Updates Subscription Advantage (SA) renewal options for installed licenses.
.PARAMETER Enabled
	Whether to enable SA renewal.
.EXAMPLE
	PS> ./Set-CitrixLicenseSARenewalOption.ps1 -Enabled $true
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	Set-LicSARenewalOptions -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated SA renewal options."
} catch {
	Write-Error $_
	exit 1
}