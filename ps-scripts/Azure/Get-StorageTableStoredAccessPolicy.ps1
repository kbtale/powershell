<#
.SYNOPSIS
	Azure: Gets storage table access policy
.DESCRIPTION
	Retrieves the stored access policies for an Azure storage table.
.PARAMETER Table
	The name of the storage table.
.PARAMETER Policy
	The name of the specific policy to retrieve (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageTableStoredAccessPolicy.ps1 -Table "users" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Table,

	[Parameter(Mandatory = $false)]
	[string]$Policy,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	
	[hashtable]$cmdArgs = @{ 'Table' = $Table; 'Context' = $ctx; 'ErrorAction' = 'Stop' }
	if ($Policy) { $cmdArgs.Add('Policy', $Policy) }

	$policies = Get-AzStorageTableStoredAccessPolicy @cmdArgs
	Write-Output $policies
} catch {
	Write-Error $_
	exit 1
}