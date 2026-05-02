<#
.SYNOPSIS
	Azure: Gets storage shares
.DESCRIPTION
	Lists file shares in an Azure storage account.
.PARAMETER Name
	The name or prefix of the share(s) to list (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageShare.ps1 -StorageAccountName "mystorage"
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

	$shares = Get-AzStorageShare @cmdArgs
	Write-Output $shares
} catch {
	Write-Error $_
	exit 1
}