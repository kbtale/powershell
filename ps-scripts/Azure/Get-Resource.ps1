<#
.SYNOPSIS
	Azure: Gets Azure resources
.DESCRIPTION
	Retrieves a list of Azure resources based on name, type, or resource group.
.PARAMETER Name
	The name of the resource (optional).
.PARAMETER ResourceGroupName
	The name of the resource group (optional).
.PARAMETER ResourceType
	The type of the resource (optional, e.g. Microsoft.Compute/virtualMachines).
.EXAMPLE
	PS> ./Get-Resource.ps1 -ResourceGroupName "MyRG" -ResourceType "Microsoft.Compute/virtualMachines"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name,

	[Parameter(Mandatory = $false)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $false)]
	[string]$ResourceType
)

try {
	Import-Module Az.Resources -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }
	if ($ResourceGroupName) { $cmdArgs.Add('ResourceGroupName', $ResourceGroupName) }
	if ($ResourceType) { $cmdArgs.Add('ResourceType', $ResourceType) }

	$resources = Get-AzResource @cmdArgs
	Write-Output $resources
} catch {
	Write-Error $_
	exit 1
}