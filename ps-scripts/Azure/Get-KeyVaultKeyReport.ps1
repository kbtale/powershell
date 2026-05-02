<#
.SYNOPSIS
	Azure: Gets a report of Key Vault keys
.DESCRIPTION
	Retrieves a summary list of keys within a specific Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.EXAMPLE
	PS> ./Get-KeyVaultKeyReport.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$keys = Get-AzKeyVaultKey -VaultName $VaultName -ErrorAction Stop | Select-Object Name, Enabled, Expires, Updated
	Write-Output $keys
} catch {
	Write-Error $_
	exit 1
}