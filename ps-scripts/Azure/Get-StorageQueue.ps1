<#
.SYNOPSIS
	Azure: Gets storage queues
.DESCRIPTION
	Lists storage queues in an Azure storage account.
.PARAMETER Name
	The name or prefix of the queue(s) to list (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageQueue.ps1 -StorageAccountName "mystorage"
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

	$queues = Get-AzStorageQueue @cmdArgs
	Write-Output $queues
} catch {
	Write-Error $_
	exit 1
}