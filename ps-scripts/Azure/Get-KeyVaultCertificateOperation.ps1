<#
.SYNOPSIS
	Azure: Gets Key Vault certificate operations
.DESCRIPTION
	Retrieves the status of a certificate creation operation in an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the certificate.
.EXAMPLE
	PS> ./Get-KeyVaultCertificateOperation.ps1 -VaultName "MyVault" -Name "MyCert"
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
	$operation = Get-AzKeyVaultCertificateOperation -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output $operation
} catch {
	Write-Error $_
	exit 1
}