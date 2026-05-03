<#
.SYNOPSIS
	Azure: Removes a storage file share
.DESCRIPTION
	Deletes an existing file share from an Azure storage account.
.PARAMETER Name
	The name of the file share to remove.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Remove-StorageShare.ps1 -Name "oldbackups" -StorageAccountName "mystorage"
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
	Remove-AzStorageShare -Name $Name -Context $ctx -Force -ErrorAction Stop
	Write-Output "Successfully removed storage share '$Name'."
} catch {
	Write-Error $_
	exit 1
}