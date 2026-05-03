<#
.SYNOPSIS
	Azure: Gets a summary of storage containers
.DESCRIPTION
	Lists a summarized view of containers in an Azure storage account.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageContainerSummary.ps1 -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$containers = Get-AzStorageContainer -Context $ctx -ErrorAction Stop | Select-Object Name, PublicAccess, LastModified
	Write-Output $containers
} catch {
	Write-Error $_
	exit 1
}