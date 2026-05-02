<#
.SYNOPSIS
	Azure: Gets storage service properties
.DESCRIPTION
	Retrieves the properties (logging, metrics, CORS) of an Azure storage account service.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageServiceProperty.ps1 -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$props = Get-AzStorageServiceProperty -Context $ctx -ErrorAction Stop
	Write-Output $props
} catch {
	Write-Error $_
	exit 1
}