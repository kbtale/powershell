<#
.SYNOPSIS
	Azure: Gets a summary report of Azure locations
.DESCRIPTION
	Retrieves a summarized list of available Azure regions.
.EXAMPLE
	PS> ./Get-LocationSummaryReport.ps1
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