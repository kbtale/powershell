<#
.SYNOPSIS
	Citrix: Gets license inventory
.DESCRIPTION
	Retrieves the inventory of all licenses available on the license server.
.EXAMPLE
	PS> ./Get-CitrixLicenseInventory.ps1
.CATEGORY Citrix
#>
param()

try {
	Import-Module Citrix.Licensing.Admin.V1 -ErrorAction Stop
	$inventory = Get-LicInventory -ErrorAction Stop
	Write-Output $inventory
} catch {
	Write-Error $_
	exit 1
}