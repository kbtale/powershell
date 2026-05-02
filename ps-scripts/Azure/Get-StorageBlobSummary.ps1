<#
.SYNOPSIS
	Azure: Gets a summary of storage blobs
.DESCRIPTION
	Lists a summarized view of blobs in a specific Azure storage container.
.PARAMETER Container
	The name of the storage container.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageBlobSummary.ps1 -Container "data" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Container,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$blobs = Get-AzStorageBlob -Container $Container -Context $ctx -ErrorAction Stop | Select-Object Name, BlobType, Length, LastModified
	Write-Output $blobs
} catch {
	Write-Error $_
	exit 1
}