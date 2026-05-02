<#
.SYNOPSIS
	Azure: Adds a contact for Key Vault certificates
.DESCRIPTION
	Adds a certificate contact to an Azure Key Vault to receive notifications about certificate lifecycle events.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER EmailAddress
	The email address of the certificate contact.
.EXAMPLE
	PS> ./Add-KeyVaultCertificateContact.ps1 -VaultName "MyVault" -EmailAddress "admin@contoso.com"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string[]]$EmailAddress
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	Add-AzKeyVaultCertificateContact -VaultName $VaultName -EmailAddress $EmailAddress -ErrorAction Stop
	Write-Output "Successfully added certificate contact(s) to vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}