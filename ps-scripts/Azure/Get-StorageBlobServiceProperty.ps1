<#
.SYNOPSIS
	Azure: Gets storage blob service properties
.DESCRIPTION
	Retrieves the properties of the blob service for an Azure storage account.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageBlobServiceProperty.ps1 -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$props = Get-AzStorageBlobServiceProperty -Context $ctx -ErrorAction Stop
	Write-Output $props
} catch {
	Write-Error $_
	exit 1
}