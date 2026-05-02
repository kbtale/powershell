<#
.SYNOPSIS
	Azure: Gets Key Vault certificate issuers
.DESCRIPTION
	Retrieves the certificate issuers configured for an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the certificate issuer.
.EXAMPLE
	PS> ./Get-KeyVaultCertificateIssuer.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop

	[hashtable]$cmdArgs = @{ 'VaultName' = $VaultName; 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$issuers = Get-AzKeyVaultCertificateIssuer @cmdArgs
	Write-Output $issuers
} catch {
	Write-Error $_
	exit 1
}