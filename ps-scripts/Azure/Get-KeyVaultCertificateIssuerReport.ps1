<#
.SYNOPSIS
	Azure: Gets a report of Key Vault certificate issuers
.DESCRIPTION
	Retrieves the list of certificate issuers for an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.EXAMPLE
	PS> ./Get-KeyVaultCertificateIssuerReport.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$issuers = Get-AzKeyVaultCertificateIssuer -VaultName $VaultName -ErrorAction Stop | Select-Object Name, IssuerProvider
	Write-Output $issuers
} catch {
	Write-Error $_
	exit 1
}