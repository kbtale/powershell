<#
.SYNOPSIS
	Azure: Backs up a Key Vault key
.DESCRIPTION
	Downloads a backup of a key from an Azure Key Vault to a file.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the key to back up.
.PARAMETER OutputFile
	The path to save the backup file.
.EXAMPLE
	PS> ./Backup-KeyVaultKey.ps1 -VaultName "MyVault" -Name "MyKey" -OutputFile "C:\backup.blob"
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
	Backup-AzKeyVaultKey -VaultName $VaultName -Name $Name -OutputFile $OutputFile -ErrorAction Stop
	Write-Output "Successfully backed up key '$Name' to '$OutputFile'."
} catch {
	Write-Error $_
	exit 1
}