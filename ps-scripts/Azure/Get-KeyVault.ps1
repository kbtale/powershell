<#
.SYNOPSIS
	Azure: Gets Azure Key Vaults
.DESCRIPTION
	Retrieves information about Azure Key Vaults in the subscription or a specific resource group.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER ResourceGroupName
	The name of the resource group.
.EXAMPLE
	PS> ./Get-KeyVault.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$VaultName,

	[Parameter(Mandatory = $false)]
	[string]$ResourceGroupName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop

	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($VaultName) { $cmdArgs.Add('VaultName', $VaultName) }
	if ($ResourceGroupName) { $cmdArgs.Add('ResourceGroupName', $ResourceGroupName) }

	$vaults = Get-AzKeyVault @cmdArgs
	Write-Output $vaults
} catch {
	Write-Error $_
	exit 1
}