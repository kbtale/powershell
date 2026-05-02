<#
.SYNOPSIS
	Citrix: Imports a license file
.DESCRIPTION
	Installs a new license file onto the Citrix license server.
.PARAMETER FilePath
	The local path to the license (.lic) file.
.EXAMPLE
	PS> ./Import-CitrixLicenseFile.ps1 -FilePath "C:\Licenses\NewLicense.lic"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$FilePath
)

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	Import-LicFile -Path $FilePath -ErrorAction Stop
	Write-Output "Successfully imported license file '$FilePath'."
} catch {
	Write-Error $_
	exit 1
}