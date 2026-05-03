<#
.SYNOPSIS
	Azure: Gets storage containers
.DESCRIPTION
	Lists storage containers in an Azure storage account.
.PARAMETER Name
	The name or prefix of the container(s) to list (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageContainer.ps1 -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	
	[hashtable]$cmdArgs = @{ 'Context' = $ctx; 'ErrorAction' = 'Stop' }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$containers = Get-AzStorageContainer @cmdArgs
	Write-Output $containers
} catch {
	Write-Error $_
	exit 1
}