<#
.SYNOPSIS
	Azure: Gets a report of Key Vault certificate operations
.DESCRIPTION
	Retrieves the status of certificate operations in an Azure Key Vault.
.PARAMETER VaultName
	The name of the Key Vault.
.EXAMPLE
	PS> ./Get-KeyVaultCertificateOperationReport.ps1 -VaultName "MyVault"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop
	$ops = Get-AzKeyVaultCertificate -VaultName $VaultName -ErrorAction Stop | ForEach-Object {
		try { Get-AzKeyVaultCertificateOperation -VaultName $VaultName -Name $_.Name -ErrorAction SilentlyContinue } catch {}
	} | Where-Object { $_ }
	Write-Output $ops
}
catch {
	Write-Error $_
	exit 1
}