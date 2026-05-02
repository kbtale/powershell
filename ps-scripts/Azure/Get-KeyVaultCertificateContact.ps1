<#
.SYNOPSIS
	Azure: Gets Key Vault certificate contacts
.DESCRIPTION
	Retrieves the certificate contacts configured for an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.EXAMPLE
	PS> ./Get-KeyVaultCertificateContact.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$contacts = Get-AzKeyVaultCertificateContact -VaultName $VaultName -ErrorAction Stop
	Write-Output $contacts
} catch {
	Write-Error $_
	exit 1
}