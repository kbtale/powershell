<#
.SYNOPSIS
	Azure: Sets a Key Vault access policy
.DESCRIPTION
	Grants or updates an access policy for a user, group, or application on an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER UserPrincipalName
	The user principal name (UPN) to grant access.
.PARAMETER PermissionsToKeys
	Array of key permissions (e.g. get, list, set, delete).
.PARAMETER PermissionsToSecrets
	Array of secret permissions (e.g. get, list, set, delete).
.PARAMETER PermissionsToCertificates
	Array of certificate permissions (e.g. get, list, delete).
.EXAMPLE
	PS> ./Set-KeyVaultAccessPolicy.ps1 -VaultName "MyVault" -UserPrincipalName "admin@contoso.com" -PermissionsToSecrets @("get", "list")
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$UserPrincipalName,

	[Parameter(Mandatory = $false)]
	[string[]]$PermissionsToKeys,

	[Parameter(Mandatory = $false)]
	[string[]]$PermissionsToSecrets,

	[Parameter(Mandatory = $false)]
	[string[]]$PermissionsToCertificates
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop

	[hashtable]$cmdArgs = @{ 'VaultName' = $VaultName; 'UserPrincipalName' = $UserPrincipalName; 'ErrorAction' = 'Stop' }
	if ($PermissionsToKeys) { $cmdArgs.Add('PermissionsToKeys', $PermissionsToKeys) }
	if ($PermissionsToSecrets) { $cmdArgs.Add('PermissionsToSecrets', $PermissionsToSecrets) }
	if ($PermissionsToCertificates) { $cmdArgs.Add('PermissionsToCertificates', $PermissionsToCertificates) }

	Set-AzKeyVaultAccessPolicy @cmdArgs | Out-Null
	Write-Output "Successfully set access policy for '$UserPrincipalName' on vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}