<#
.SYNOPSIS
	Azure: Gets a report of storage accounts
.DESCRIPTION
	Retrieves a summary list of Azure storage accounts in the subscription.
.EXAMPLE
	PS> ./Get-StorageAccountReport.ps1
.CATEGORY Azure
#>
param()

try {
	Import-Module Az.Storage -ErrorAction Stop
	$accounts = Get-AzStorageAccount -ErrorAction Stop | Select-Object StorageAccountName, ResourceGroupName, Location, SkuName
	Write-Output $accounts
} catch {
	Write-Error $_
	exit 1
}