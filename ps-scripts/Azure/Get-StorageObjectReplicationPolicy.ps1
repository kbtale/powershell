<#
.SYNOPSIS
	Azure: Gets storage object replication policy
.DESCRIPTION
	Retrieves the object replication policies for an Azure storage account.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageObjectReplicationPolicy.ps1 -ResourceGroupName "MyRG" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$policies = Get-AzStorageObjectReplicationPolicy -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -ErrorAction Stop
	Write-Output $policies
} catch {
	Write-Error $_
	exit 1
}