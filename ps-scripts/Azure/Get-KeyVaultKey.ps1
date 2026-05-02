<#
.SYNOPSIS
	Azure: Gets Key Vault keys
.DESCRIPTION
	Retrieves keys or information about a specific key from an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the key (optional).
.EXAMPLE
	PS> ./Get-KeyVaultKey.ps1 -VaultName "MyVault"
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

	$keys = Get-AzKeyVaultKey @cmdArgs
	Write-Output $keys
} catch {
	Write-Error $_
	exit 1
}