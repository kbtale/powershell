<#
.SYNOPSIS
	Azure: Gets a report of virtual machines
.DESCRIPTION
	Retrieves a summary list of virtual machines in the subscription or a specific resource group.
.PARAMETER ResourceGroupName
	The name of the resource group (optional).
.EXAMPLE
	PS> ./Get-VMReport.ps1
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$ResourceGroupName
)

try {
	Import-Module Az.Compute -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($ResourceGroupName) { $cmdArgs.Add('ResourceGroupName', $ResourceGroupName) }

	$vms = Get-AzVM @cmdArgs | Select-Object Name, ResourceGroupName, Location, ProvisioningState, @{N='PowerState'; E={(Get-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Status).Statuses[1].DisplayStatus}}
	Write-Output $vms
} catch {
	Write-Error $_
	exit 1
}