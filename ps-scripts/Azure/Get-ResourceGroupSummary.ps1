<#
.SYNOPSIS
	Azure: Gets a summary of resource groups
.DESCRIPTION
	Retrieves a summarized list of Azure resource groups in the subscription.
.EXAMPLE
	PS> ./Get-ResourceGroupSummary.ps1
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