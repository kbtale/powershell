<#
.SYNOPSIS
	Azure: Creates a network security group
.DESCRIPTION
	Creates a new Azure network security group in a specified resource group and location.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER Name
	The name of the network security group.
.PARAMETER Location
	The Azure region where the resource will be created.
.EXAMPLE
	PS> ./New-NetworkSecurityGroup.ps1 -ResourceGroupName "MyRG" -Name "MyNSG" -Location "EastUS"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$Location
)

try {
	Import-Module Az.Network -ErrorAction Stop
	$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $Name -Location $Location -ErrorAction Stop
	Write-Output $nsg
} catch {
	Write-Error $_
	exit 1
}