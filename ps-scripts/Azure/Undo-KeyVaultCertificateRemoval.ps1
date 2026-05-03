<#
.SYNOPSIS
	Azure: Undoes a Key Vault certificate removal
.DESCRIPTION
	Recovers a previously deleted certificate from an Azure Key Vault that has soft-delete enabled.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the certificate to recover.
.EXAMPLE
	PS> ./Undo-KeyVaultCertificateRemoval.ps1 -VaultName "MyVault" -Name "MyCert"
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
	$cert = Undo-AzKeyVaultCertificateRemoval -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output "Successfully recovered certificate '$Name' in vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}