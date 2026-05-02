<#
.SYNOPSIS
	Azure: Gets a report of Azure locations
.DESCRIPTION
	Retrieves a summary list of available Azure regions.
.EXAMPLE
	PS> ./Get-LocationReport.ps1
.CATEGORY Azure
#>
param()

try {
	Import-Module Az.Resources -ErrorAction Stop
	$locations = Get-AzLocation -ErrorAction Stop | Select-Object Location, DisplayName
	Write-Output $locations
} catch {
	Write-Error $_
	exit 1
}