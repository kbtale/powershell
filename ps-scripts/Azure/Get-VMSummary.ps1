<#
.SYNOPSIS
	Azure: Gets a summary of virtual machines
.DESCRIPTION
	Retrieves a summarized list of virtual machines in the subscription.
.EXAMPLE
	PS> ./Get-VMSummary.ps1
.CATEGORY Azure
#>
param()

try {
	Import-Module Az.Compute -ErrorAction Stop
	$vms = Get-AzVM -ErrorAction Stop | Select-Object Name, ResourceGroupName, Location, ProvisioningState
	Write-Output $vms
} catch {
	Write-Error $_
	exit 1
}