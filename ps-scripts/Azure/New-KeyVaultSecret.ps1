<#
.SYNOPSIS
	Azure: Creates or updates a Key Vault secret
.DESCRIPTION
	Creates a new secret or updates an existing secret in an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the secret.
.PARAMETER SecretValue
	The plaintext value of the secret.
.EXAMPLE
	PS> ./New-KeyVaultSecret.ps1 -VaultName "MyVault" -Name "MySecret" -SecretValue "MySuperSecretValue"
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
	$secureString = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force
	$secret = Set-AzKeyVaultSecret -VaultName $VaultName -Name $Name -SecretValue $secureString -ErrorAction Stop
	Write-Output "Successfully created or updated secret '$Name' in vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}