<#
.SYNOPSIS
	Azure: Removes a Key Vault certificate operation
.DESCRIPTION
	Removes an ongoing or stuck certificate operation in an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the certificate whose operation to remove.
.EXAMPLE
	PS> ./Remove-KeyVaultCertificateOperation.ps1 -VaultName "MyVault" -Name "MyCert"
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
	Remove-AzKeyVaultCertificateOperation -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully removed certificate operation for '$Name' in vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}