<#
.SYNOPSIS
	Azure: Gets storage queue access policy
.DESCRIPTION
	Retrieves the stored access policies for an Azure storage queue.
.PARAMETER Queue
	The name of the storage queue.
.PARAMETER Policy
	The name of the specific policy to retrieve (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageQueueStoredAccessPolicy.ps1 -Queue "orders" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Queue,

	[Parameter(Mandatory = $false)]
	[string]$Policy,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	
	[hashtable]$cmdArgs = @{ 'Queue' = $Queue; 'Context' = $ctx; 'ErrorAction' = 'Stop' }
	if ($Policy) { $cmdArgs.Add('Policy', $Policy) }

	$policies = Get-AzStorageQueueStoredAccessPolicy @cmdArgs
	Write-Output $policies
} catch {
	Write-Error $_
	exit 1
}