<#
.SYNOPSIS
	Azure: Removes a resource group
.DESCRIPTION
	Deletes an existing Azure resource group and all contained resources.
.PARAMETER Name
	The name of the resource group to remove.
.EXAMPLE
	PS> ./Remove-ResourceGroup.ps1 -Name "MyOldRG"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Az.Resources -ErrorAction Stop
	Remove-AzResourceGroup -Name $Name -Force -ErrorAction Stop
	Write-Output "Successfully removed resource group '$Name'."
} catch {
	Write-Error $_
	exit 1
}