<#
.SYNOPSIS
	Azure: Removes a Key Vault secret
.DESCRIPTION
	Removes a secret from an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the secret to remove.
.EXAMPLE
	PS> ./Remove-KeyVaultSecret.ps1 -VaultName "MyVault" -Name "MySecret"
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
	Remove-AzKeyVaultSecret -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully removed secret '$Name' from vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}