<#
.SYNOPSIS
	Azure: Gets storage service metrics properties
.DESCRIPTION
	Retrieves the metrics settings for an Azure storage service.
.PARAMETER ServiceType
	The type of storage service (Blob, Table, Queue).
.PARAMETER MetricsType
	The type of metrics (Hour, Minute).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageServiceMetricsProperty.ps1 -ServiceType Blob -MetricsType Hour -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[ValidateSet('Blob', 'Table', 'Queue')]
	[string]$ServiceType,

	[Parameter(Mandatory = $true)]
	[ValidateSet('Hour', 'Minute')]
	[string]$MetricsType,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$props = Get-AzStorageServiceMetricsProperty -ServiceType $ServiceType -MetricsType $MetricsType -Context $ctx -ErrorAction Stop
	Write-Output $props
} catch {
	Write-Error $_
	exit 1
}