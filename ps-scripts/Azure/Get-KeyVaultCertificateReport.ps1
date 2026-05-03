<#
.SYNOPSIS
	Azure: Gets a report of Key Vault certificates
.DESCRIPTION
	Retrieves a summary list of certificates within a specific Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.EXAMPLE
	PS> ./Get-KeyVaultCertificateReport.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$certs = Get-AzKeyVaultCertificate -VaultName $VaultName -ErrorAction Stop | Select-Object Name, Enabled, Expires, Updated
	Write-Output $certs
} catch {
	Write-Error $_
	exit 1
}