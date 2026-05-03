<#
.SYNOPSIS
	Azure: Gets storage service logging properties
.DESCRIPTION
	Retrieves the logging settings for an Azure storage service.
.PARAMETER ServiceType
	The type of storage service (Blob, Table, Queue).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageServiceLoggingProperty.ps1 -ServiceType Blob -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[ValidateSet('Blob', 'Table', 'Queue')]
	[string]$ServiceType,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$props = Get-AzStorageServiceLoggingProperty -ServiceType $ServiceType -Context $ctx -ErrorAction Stop
	Write-Output $props
} catch {
	Write-Error $_
	exit 1
}