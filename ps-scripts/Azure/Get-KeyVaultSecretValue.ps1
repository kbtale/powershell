<#
.SYNOPSIS
	Azure: Gets Key Vault secret value
.DESCRIPTION
	Retrieves the plaintext value of a specific secret from an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the secret.
.EXAMPLE
	PS> ./Get-KeyVaultSecretValue.ps1 -VaultName "MyVault" -Name "MySecret"
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
	$secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Name -AsPlainText -ErrorAction Stop
	Write-Output $secret
} catch {
	Write-Error $_
	exit 1
}