<#
.SYNOPSIS
	Azure: Removes a storage container
.DESCRIPTION
	Deletes an existing container from an Azure storage account.
.PARAMETER Name
	The name of the container to remove.
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Remove-StorageContainer.ps1 -Name "temp" -StorageAccountName "mystorage"
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
	Remove-AzStorageContainer -Name $Name -Context $ctx -Force -ErrorAction Stop
	Write-Output "Successfully removed storage container '$Name'."
} catch {
	Write-Error $_
	exit 1
}