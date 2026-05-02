<#
.SYNOPSIS
	Azure: Uploads a storage blob
.DESCRIPTION
	Uploads a local file as a blob to a specified Azure storage container.
.PARAMETER Container
	The name of the destination storage container.
.PARAMETER FilePath
	The local path to the file to upload.
.PARAMETER BlobName
	The name for the blob in the container (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Set-StorageBlobContent.ps1 -Container "uploads" -FilePath "C:\data\report.xlsx" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Container,

	[Parameter(Mandatory = $true)]
	[string]$FilePath,

	[Parameter(Mandatory = $false)]
	[string]$BlobName,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	
	[hashtable]$cmdArgs = @{ 'Container' = $Container; 'File' = $FilePath; 'Context' = $ctx; 'Force' = $true; 'ErrorAction' = 'Stop' }
	if ($BlobName) { $cmdArgs.Add('Blob', $BlobName) }

	$blob = Set-AzStorageBlobContent @cmdArgs
	Write-Output $blob
} catch {
	Write-Error $_
	exit 1
}