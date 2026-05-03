<#
.SYNOPSIS
	Azure: Gets a summary of Azure resources
.DESCRIPTION
	Retrieves a summarized list of resources in the Azure subscription.
.EXAMPLE
	PS> ./Get-ResourceSummary.ps1
.CATEGORY Azure
#>
param()

try {
	Import-Module Az.Resources -ErrorAction Stop
	$resources = Get-AzResource -ErrorAction Stop | Select-Object Name, ResourceType, ResourceGroupName, Location
	Write-Output $resources
} catch {
	Write-Error $_
	exit 1
}