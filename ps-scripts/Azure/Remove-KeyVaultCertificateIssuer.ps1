<#
.SYNOPSIS
	Azure: Removes a Key Vault certificate issuer
.DESCRIPTION
	Removes a certificate issuer from an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the certificate issuer to remove.
.EXAMPLE
	PS> ./Remove-KeyVaultCertificateIssuer.ps1 -VaultName "MyVault" -Name "MyIssuer"
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
	Remove-AzKeyVaultCertificateIssuer -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully removed certificate issuer '$Name' from vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}