<#
.SYNOPSIS
	Azure: Gets Key Vault secrets
.DESCRIPTION
	Retrieves secrets or information about a specific secret from an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the secret (optional).
.EXAMPLE
	PS> ./Get-KeyVaultSecret.ps1 -VaultName "MyVault"
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

	$secrets = Get-AzKeyVaultSecret @cmdArgs
	Write-Output $secrets
} catch {
	Write-Error $_
	exit 1
}