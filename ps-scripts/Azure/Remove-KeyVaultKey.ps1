<#
.SYNOPSIS
	Azure: Removes a Key Vault key
.DESCRIPTION
	Removes a key from an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the key to remove.
.EXAMPLE
	PS> ./Remove-KeyVaultKey.ps1 -VaultName "MyVault" -Name "MyKey"
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
	Remove-AzKeyVaultKey -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully removed key '$Name' from vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}