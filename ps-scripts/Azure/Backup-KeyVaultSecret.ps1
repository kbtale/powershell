<#
.SYNOPSIS
	Azure: Backs up a Key Vault secret
.DESCRIPTION
	Downloads a backup of a secret from an Azure Key Vault to a file.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the secret to back up.
.PARAMETER OutputFile
	The path to save the backup file.
.EXAMPLE
	PS> ./Backup-KeyVaultSecret.ps1 -VaultName "MyVault" -Name "MySecret" -OutputFile "C:\backup.blob"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$OutputFile
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	Backup-AzKeyVaultSecret -VaultName $VaultName -Name $Name -OutputFile $OutputFile -ErrorAction Stop
	Write-Output "Successfully backed up secret '$Name' to '$OutputFile'."
} catch {
	Write-Error $_
	exit 1
}