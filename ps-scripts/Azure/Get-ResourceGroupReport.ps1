<#
.SYNOPSIS
	Azure: Gets a report of resource groups
.DESCRIPTION
	Retrieves a summary list of Azure resource groups in the current subscription.
.EXAMPLE
	PS> ./Get-ResourceGroupReport.ps1
.CATEGORY Azure
#>
param()

try {
	Import-Module Az.Resources -ErrorAction Stop
	$rgs = Get-AzResourceGroup -ErrorAction Stop | Select-Object ResourceGroupName, Location, ProvisioningState
	Write-Output $rgs
} catch {
	Write-Error $_
	exit 1
}