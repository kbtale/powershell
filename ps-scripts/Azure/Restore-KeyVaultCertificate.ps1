<#
.SYNOPSIS
	Azure: Restores a Key Vault certificate
.DESCRIPTION
	Restores a certificate from a backup file to an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER InputFile
	The path to the backup file to restore.
.EXAMPLE
	PS> ./Restore-KeyVaultCertificate.ps1 -VaultName "MyVault" -InputFile "C:\backup.blob"
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
	$cert = Restore-AzKeyVaultCertificate -VaultName $VaultName -InputFile $InputFile -ErrorAction Stop
	Write-Output "Successfully restored certificate to vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}