<#
.SYNOPSIS
	Azure: Gets network security groups
.DESCRIPTION
	Retrieves information about network security groups in a resource group or subscription.
.PARAMETER ResourceGroupName
	The name of the resource group (optional).
.PARAMETER Name
	The name of the network security group (optional).
.EXAMPLE
	PS> ./Get-NetworkSecurityGroup.ps1 -ResourceGroupName "MyResourceGroup"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Az.Network -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($ResourceGroupName) { $cmdArgs.Add('ResourceGroupName', $ResourceGroupName) }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$nsgs = Get-AzNetworkSecurityGroup @cmdArgs
	Write-Output $nsgs
} catch {
	Write-Error $_
	exit 1
}