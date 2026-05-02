<#
.SYNOPSIS
	Azure: Creates a resource group
.DESCRIPTION
	Creates a new Azure resource group in a specified location.
.PARAMETER Name
	The name of the resource group.
.PARAMETER Location
	The Azure region where the resource group will be created.
.EXAMPLE
	PS> ./New-ResourceGroup.ps1 -Name "MyNewRG" -Location "WestUS"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$Location
)

try {
	Import-Module Az.Resources -ErrorAction Stop
	$rg = New-AzResourceGroup -Name $Name -Location $Location -ErrorAction Stop
	Write-Output $rg
} catch {
	Write-Error $_
	exit 1
}