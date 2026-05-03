<#
.SYNOPSIS
	Azure: Gets a summary of storage tables
.DESCRIPTION
	Lists a summarized view of tables in an Azure storage account.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageTableSummary.ps1 -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$tables = Get-AzStorageTable -Context $ctx -ErrorAction Stop | Select-Object Name
	Write-Output $tables
} catch {
	Write-Error $_
	exit 1
}