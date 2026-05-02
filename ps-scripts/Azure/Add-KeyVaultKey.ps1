<#
.SYNOPSIS
	Azure: Adds a key to a Key Vault
.DESCRIPTION
	Creates a new key or imports an existing key into an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name of the key to create.
.PARAMETER Destination
	The destination of the key (Software or HSM).
.EXAMPLE
	PS> ./Add-KeyVaultKey.ps1 -VaultName "MyVault" -Name "MyKey" -Destination "Software"
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
	Add-AzKeyVaultKey -VaultName $VaultName -Name $Name -Destination $Destination -ErrorAction Stop
	Write-Output "Successfully added key '$Name' to vault '$VaultName'."
} catch {
	Write-Error $_
	exit 1
}