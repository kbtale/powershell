<#
.SYNOPSIS
	Citrix: Sets license config usage samples
.DESCRIPTION
	Updates the configuration for license usage sampling.
.PARAMETER Enabled
	Whether to enable usage sampling.
.EXAMPLE
	PS> ./Set-CitrixLicenseConfigUsageSamples.ps1 -Enabled $true
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[bool]$Enabled
)

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	Set-LicConfigUsageSamples -Enabled $Enabled -ErrorAction Stop
	Write-Output "Successfully updated license config usage sampling."
} catch {
	Write-Error $_
	exit 1
}