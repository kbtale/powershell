<#
.SYNOPSIS
	Azure: Removes a network security group
.DESCRIPTION
	Deletes an existing network security group from a resource group.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER Name
	The name of the network security group.
.EXAMPLE
	PS> ./Remove-NetworkSecurityGroup.ps1 -ResourceGroupName "MyRG" -Name "MyNSG"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Az.Network -ErrorAction Stop
	Remove-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed network security group '$Name'."
} catch {
	Write-Error $_
	exit 1
}