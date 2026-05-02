<#
.SYNOPSIS
	Azure: Gets a report of storage containers
.DESCRIPTION
	Retrieves a summary list of containers within a specific Azure storage account.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageContainerReport.ps1 -StorageAccountName "mystorage"
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