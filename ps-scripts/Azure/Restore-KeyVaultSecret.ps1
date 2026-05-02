<#
.SYNOPSIS
	Azure: Restores a Key Vault secret
.DESCRIPTION
	Restores a secret from a backup file to an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER InputFile
	The path to the backup file to restore.
.EXAMPLE
	PS> ./Restore-KeyVaultSecret.ps1 -VaultName "MyVault" -InputFile "C:\backup.blob"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$InputFile
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$secret = Restore-AzKeyVaultSecret -VaultName $VaultName -InputFile $InputFile -ErrorAction Stop
	Write-Output "Successfully restored secret to vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}