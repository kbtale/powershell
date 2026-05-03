<#
.SYNOPSIS
	Azure: Gets a summary of storage shares
.DESCRIPTION
	Lists a summarized view of file shares in an Azure storage account.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageShareSummary.ps1 -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$shares = Get-AzStorageShare -Context $ctx -ErrorAction Stop | Select-Object Name, Quota, LastModified
	Write-Output $shares
} catch {
	Write-Error $_
	exit 1
}