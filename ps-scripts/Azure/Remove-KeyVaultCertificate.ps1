<#
.SYNOPSIS
	Azure: Removes a Key Vault certificate
.DESCRIPTION
	Removes a certificate from the specified Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the certificate to remove.
.EXAMPLE
	PS> ./Remove-KeyVaultCertificate.ps1 -VaultName "MyVault" -Name "MyCert"
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
	Remove-AzKeyVaultCertificate -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully removed certificate '$Name' from vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}