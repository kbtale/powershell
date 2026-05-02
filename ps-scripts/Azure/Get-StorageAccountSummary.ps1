<#
.SYNOPSIS
	Azure: Gets a summary of storage accounts
.DESCRIPTION
	Retrieves a summarized list of Azure storage accounts.
.EXAMPLE
	PS> ./Get-StorageAccountSummary.ps1
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