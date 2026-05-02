<#
.SYNOPSIS
	Azure: Gets Azure locations
.DESCRIPTION
	Retrieves the list of available Azure regions for the current subscription.
.EXAMPLE
	PS> ./Get-Location.ps1
.CATEGORY Azure
#>
param()

try {
	Import-Module Az.Resources -ErrorAction Stop
	$locations = Get-AzLocation -ErrorAction Stop | Select-Object Location, DisplayName, RegionalDisplayName
	Write-Output $locations
} catch {
	Write-Error $_
	exit 1
}