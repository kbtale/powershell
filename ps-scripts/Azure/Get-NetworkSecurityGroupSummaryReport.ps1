<#
.SYNOPSIS
	Azure: Gets a summary report of network security groups
.DESCRIPTION
	Retrieves a summarized list of network security groups in the subscription or a resource group.
.PARAMETER ResourceGroupName
	The name of the resource group (optional).
.EXAMPLE
	PS> ./Get-NetworkSecurityGroupSummaryReport.ps1
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$ResourceGroupName
)

try {
	Import-Module Az.Network -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($ResourceGroupName) { $cmdArgs.Add('ResourceGroupName', $ResourceGroupName) }

	$nsgs = Get-AzNetworkSecurityGroup @cmdArgs | Select-Object Name, ResourceGroupName, Location, @{N='RuleCount'; E={$_.SecurityRules.Count}}
	Write-Output $nsgs
} catch {
	Write-Error $_
	exit 1
}