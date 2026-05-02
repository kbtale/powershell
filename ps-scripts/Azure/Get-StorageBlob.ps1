<#
.SYNOPSIS
	Azure: Gets storage blobs
.DESCRIPTION
	Lists blobs in a specific Azure storage container.
.PARAMETER Container
	The name of the storage container.
.PARAMETER Blob
	The name or prefix of the blob(s) to list (optional).
.PARAMETER StorageAccountName
	The name of the storage account for context.
.EXAMPLE
	PS> ./Get-StorageBlob.ps1 -Container "images" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Container,

	[Parameter(Mandatory = $false)]
	[string]$Blob,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	
	[hashtable]$cmdArgs = @{ 'Container' = $Container; 'Context' = $ctx; 'ErrorAction' = 'Stop' }
	if ($Blob) { $cmdArgs.Add('Blob', $Blob) }

	$blobs = Get-AzStorageBlob @cmdArgs
	Write-Output $blobs
} catch {
	Write-Error $_
	exit 1
}