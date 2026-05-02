<#
.SYNOPSIS
	Azure: Gets storage tables
.DESCRIPTION
	Lists tables in an Azure storage account.
.PARAMETER Name
	The name or prefix of the table(s) to list (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./Get-StorageTable.ps1 -StorageAccountName "mystorage"
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

	$tables = Get-AzStorageTable @cmdArgs
	Write-Output $tables
} catch {
	Write-Error $_
	exit 1
}