<#
.SYNOPSIS
	Azure: Gets storage container access policy
.DESCRIPTION
	Retrieves the stored access policies for an Azure storage container.
.PARAMETER Container
	The name of the storage container.
.PARAMETER Policy
	The name of the specific policy to retrieve (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageContainerStoredAccessPolicy.ps1 -Container "data" -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Container,

	[Parameter(Mandatory = $false)]
	[string]$Policy,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	
	[hashtable]$cmdArgs = @{ 'Container' = $Container; 'Context' = $ctx; 'ErrorAction' = 'Stop' }
	if ($Policy) { $cmdArgs.Add('Policy', $Policy) }

	$policies = Get-AzStorageContainerStoredAccessPolicy @cmdArgs
	Write-Output $policies
} catch {
	Write-Error $_
	exit 1
}