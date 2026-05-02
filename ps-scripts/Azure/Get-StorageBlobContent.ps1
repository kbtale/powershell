<#
.SYNOPSIS
	Azure: Downloads a storage blob
.DESCRIPTION
	Downloads the content of a specific blob from an Azure storage container to a local file.
.PARAMETER Container
	The name of the storage container.
.PARAMETER Blob
	The name of the blob.
.PARAMETER Destination
	The local path where the blob will be saved.
.PARAMETER StorageAccountName
	The name of the storage account for context.
.EXAMPLE
	PS> ./Get-StorageBlobContent.ps1 -Container "data" -Blob "report.pdf" -Destination "C:\Downloads\report.pdf" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Container,

	[Parameter(Mandatory = $true)]
	[string]$Blob,

	[Parameter(Mandatory = $true)]
	[string]$Destination,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	Get-AzStorageBlobContent -Container $Container -Blob $Blob -Destination $Destination -Context $ctx -Force -ErrorAction Stop | Out-Null
	Write-Output "Successfully downloaded blob '$Blob' to '$Destination'."
} catch {
	Write-Error $_
	exit 1
}