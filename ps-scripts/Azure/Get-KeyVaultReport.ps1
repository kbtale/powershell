<#
.SYNOPSIS
	Azure: Gets a report of Key Vaults
.DESCRIPTION
	Retrieves a summary list of Azure Key Vaults in the subscription.
.EXAMPLE
	PS> ./Get-KeyVaultReport.ps1
.CATEGORY Azure
#>
param()

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$vaults = Get-AzKeyVault -ErrorAction Stop | Select-Object VaultName, ResourceGroupName, Location, Tags
	Write-Output $vaults
} catch {
	Write-Error $_
	exit 1
}