<#
.SYNOPSIS
	Azure: Gets a report of Key Vault certificate contacts
.DESCRIPTION
	Retrieves the list of certificate contacts for an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.EXAMPLE
	PS> ./Get-KeyVaultCertificateContactReport.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$contacts = Get-AzKeyVaultCertificateContact -VaultName $VaultName -ErrorAction Stop | Select-Object EmailAddress, VaultName
	Write-Output $contacts
} catch {
	Write-Error $_
	exit 1
}