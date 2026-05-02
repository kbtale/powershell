<#
.SYNOPSIS
	Azure: Sets or updates a Key Vault secret
.DESCRIPTION
	Creates a new secret or updates an existing secret in an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the secret.
.PARAMETER SecretValue
	The plaintext value of the secret.
.EXAMPLE
	PS> ./Set-KeyVaultSecret.ps1 -VaultName "MyVault" -Name "MySecret" -SecretValue "MySecretContent"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$SecretValue
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$secureSecret = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force
	$secret = Set-AzKeyVaultSecret -VaultName $VaultName -Name $Name -SecretValue $secureSecret -ErrorAction Stop
	Write-Output "Successfully set secret '$Name' in vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}