<#
.SYNOPSIS
	Azure: Creates a storage table
.DESCRIPTION
	Creates a new table in an Azure storage account.
.PARAMETER Name
	The name for the new table.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./New-StorageTable.ps1 -Name "Logs" -StorageAccountName "mystorage"
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
	$table = New-AzStorageTable -Name $Name -Context $ctx -ErrorAction Stop
	Write-Output $table
} catch {
	Write-Error $_
	exit 1
}