<#
.SYNOPSIS
	Azure: Gets Key Vault certificate policy
.DESCRIPTION
	Retrieves the policy for a certificate in an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the certificate.
.EXAMPLE
	PS> ./Get-KeyVaultCertificatePolicy.ps1 -VaultName "MyVault" -Name "MyCert"
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
	$policy = Get-AzKeyVaultCertificatePolicy -VaultName $VaultName -Name $Name -ErrorAction Stop
	Write-Output $policy
} catch {
	Write-Error $_
	exit 1
}