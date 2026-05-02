<#
.SYNOPSIS
	Azure: Undoes a Key Vault key removal
.DESCRIPTION
	Recovers a previously deleted key from an Azure Key Vault that has soft-delete enabled.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the key to recover.
.EXAMPLE
	PS> ./Undo-KeyVaultKeyRemoval.ps1 -VaultName "MyVault" -Name "MyKey"
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
	$key = Undo-AzKeyVaultKeyRemoval -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully recovered key '$Name' in vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}