<#
.SYNOPSIS
	Citrix: Sets the license server
.DESCRIPTION
	Updates the license server address and port for the Citrix site.
.PARAMETER LicenseServerAddress
	The FQDN or IP of the license server.
.PARAMETER LicenseServerPort
	The port used by the license server (default 27000).
.EXAMPLE
	PS> ./Set-CitrixLicenseServer.ps1 -LicenseServerAddress "lic.contoso.com"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$LicenseServerAddress,

	[Parameter(Mandatory = $false)]
	[int]$LicenseServerPort = 27000
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	Set-BrokerSite -LicenseServerAddress $LicenseServerAddress -LicenseServerPort $LicenseServerPort -ErrorAction Stop
	Write-Output "Successfully updated license server to '$LicenseServerAddress'."
} catch {
	Write-Error $_
	exit 1
}