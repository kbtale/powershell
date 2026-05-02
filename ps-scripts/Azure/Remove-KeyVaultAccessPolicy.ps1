<#
.SYNOPSIS
	Azure: Removes a Key Vault access policy
.DESCRIPTION
	Removes an access policy from an Azure Key Vault for a specific user, group, or application.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER UserPrincipalName
	The user principal name (UPN) to remove from the policy.
.EXAMPLE
	PS> ./Remove-KeyVaultAccessPolicy.ps1 -VaultName "MyVault" -UserPrincipalName "admin@contoso.com"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$UserPrincipalName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	Remove-AzKeyVaultAccessPolicy -VaultName $VaultName -UserPrincipalName $UserPrincipalName -ErrorAction Stop
	Write-Output "Successfully removed access policy for '$UserPrincipalName' from vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}