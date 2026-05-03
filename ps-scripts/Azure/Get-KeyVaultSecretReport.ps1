<#
.SYNOPSIS
	Azure: Gets a report of Key Vault secrets
.DESCRIPTION
	Retrieves a summary list of secrets within a specific Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.EXAMPLE
	PS> ./Get-KeyVaultSecretReport.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$secrets = Get-AzKeyVaultSecret -VaultName $VaultName -ErrorAction Stop | Select-Object Name, Enabled, Expires, Updated
	Write-Output $secrets
} catch {
	Write-Error $_
	exit 1
}