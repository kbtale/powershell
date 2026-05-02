<#
.SYNOPSIS
	Azure: Imports a Key Vault certificate
.DESCRIPTION
	Imports an existing certificate into an Azure Key Vault from a file.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name for the certificate in the vault.
.PARAMETER FilePath
	The path to the certificate file (.pfx or .pem).
.EXAMPLE
	PS> ./Import-KeyVaultCertificate.ps1 -VaultName "MyVault" -Name "MyCert" -FilePath "C:\cert.pfx"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$FilePath
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$cert = Import-AzKeyVaultCertificate -VaultName $VaultName -Name $Name -FilePath $FilePath -ErrorAction Stop
	Write-Output "Successfully imported certificate '$Name' to vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}