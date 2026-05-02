<#
.SYNOPSIS
	Azure: Gets Key Vault key rotation policy
.DESCRIPTION
	Retrieves the rotation policy for a specific key in an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the key.
.EXAMPLE
	PS> ./Get-KeyVaultKeyRotationPolicy.ps1 -VaultName "MyVault" -Name "MyKey"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$Name
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$policy = Get-AzKeyVaultKeyRotationPolicy -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output $policy
} catch {
	Write-Error $_
	exit 1
}