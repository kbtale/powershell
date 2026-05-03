<#
.SYNOPSIS
	Azure: Removes a storage table
.DESCRIPTION
	Deletes an existing table from an Azure storage account.
.PARAMETER Name
	The name of the table to remove.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Remove-StorageTable.ps1 -Name "OldLogs" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	Remove-AzStorageTable -Name $Name -Context $ctx -Force -ErrorAction Stop
	Write-Output "Successfully removed storage table '$Name'."
} catch {
	Write-Error $_
	exit 1
}