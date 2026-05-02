<#
.SYNOPSIS
	Azure: Sets or updates a Key Vault key
.DESCRIPTION
	Creates a new key or updates an existing key in an Azure Key Vault with specified attributes.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the key.
.PARAMETER Destination
	The destination for the key (Software or HSM).
.EXAMPLE
	PS> ./Set-KeyVaultKey.ps1 -VaultName "MyVault" -Name "MyKey" -Destination "Software"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $false)]
	[ValidateSet('Software', 'HSM')]
	[string]$Destination = 'Software'
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$key = Add-AzKeyVaultKey -VaultName $VaultName -Name $Name -Destination $Destination -ErrorAction Stop
	Write-Output $key
} catch {
	Write-Error $_
	exit 1
}