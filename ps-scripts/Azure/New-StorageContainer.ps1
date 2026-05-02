<#
.SYNOPSIS
	Azure: Creates a storage container
.DESCRIPTION
	Creates a new container in an Azure storage account.
.PARAMETER Name
	The name for the new container.
.PARAMETER Permission
	The public access level (Off, Blob, Container).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./New-StorageContainer.ps1 -Name "logs" -Permission Off -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $false)]
	[ValidateSet('Off', 'Blob', 'Container')]
	[string]$Permission = 'Off',

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	$container = New-AzStorageContainer -Name $Name -Permission $Permission -Context $ctx -ErrorAction Stop
	Write-Output $container
} catch {
	Write-Error $_
	exit 1
}