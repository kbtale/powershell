<#
.SYNOPSIS
	Azure: Removes a Key Vault certificate contact
.DESCRIPTION
	Removes a certificate contact from an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER EmailAddress
	The email address of the certificate contact to remove.
.EXAMPLE
	PS> ./Remove-KeyVaultCertificateContact.ps1 -VaultName "MyVault" -EmailAddress "admin@contoso.com"
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
	Remove-AzKeyVaultCertificateContact -VaultName $VaultName -EmailAddress $EmailAddress -ErrorAction Stop
	Write-Output "Successfully removed certificate contact(s) from vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}