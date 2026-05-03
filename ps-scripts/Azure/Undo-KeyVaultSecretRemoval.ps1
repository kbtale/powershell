<#
.SYNOPSIS
	Azure: Undoes a Key Vault secret removal
.DESCRIPTION
	Recovers a previously deleted secret from an Azure Key Vault that has soft-delete enabled.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the secret to recover.
.EXAMPLE
	PS> ./Undo-KeyVaultSecretRemoval.ps1 -VaultName "MyVault" -Name "MySecret"
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
	$secret = Undo-AzKeyVaultSecretRemoval -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully recovered secret '$Name' in vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}