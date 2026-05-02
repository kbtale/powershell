<#
.SYNOPSIS
	Azure: Invokes Key Vault key rotation
.DESCRIPTION
	Triggers the rotation of a specific key in an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the key to rotate.
.EXAMPLE
	PS> ./Invoke-KeyVaultKeyRotation.ps1 -VaultName "MyVault" -Name "MyKey"
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
	Invoke-AzKeyVaultKeyRotation -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully triggered rotation for key '$Name' in vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}