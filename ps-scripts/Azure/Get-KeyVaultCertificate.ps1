<#
.SYNOPSIS
	Azure: Gets Key Vault certificates
.DESCRIPTION
	Retrieves certificates from an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the certificate.
.EXAMPLE
	PS> ./Get-KeyVaultCertificate.ps1 -VaultName "MyVault"
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

	$certs = Get-AzKeyVaultCertificate @cmdArgs
	Write-Output $certs
} catch {
	Write-Error $_
	exit 1
}