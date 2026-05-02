<#
.SYNOPSIS
	Azure: Gets storage CORS rules
.DESCRIPTION
	Retrieves the Cross-Origin Resource Sharing (CORS) rules for an Azure storage service.
.PARAMETER ServiceType
	The type of storage service (Blob, Table, Queue, File).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageCORSRule.ps1 -ServiceType Blob -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[ValidateSet('Blob', 'Table', 'Queue', 'File')]
	[string]$ServiceType,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$rules = Get-AzStorageCORSRule -ServiceType $ServiceType -Context $ctx -ErrorAction Stop
	Write-Output $rules
} catch {
	Write-Error $_
	exit 1
}