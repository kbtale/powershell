<#
.SYNOPSIS
	Azure: Creates a storage file share
.DESCRIPTION
	Creates a new file share in an Azure storage account.
.PARAMETER Name
	The name for the new file share.
.PARAMETER Quota
	The maximum size of the share in GB (optional).
.PARAMETER StorageAccountName
	The name of the storage account.
.EXAMPLE
	PS> ./New-StorageShare.ps1 -Name "backups" -Quota 100 -StorageAccountName "mystorage"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $false)]
	[int]$Quota,

	[Parameter(Mandatory = $true)]
	[string]$StorageAccountName
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	$ctx = (Get-AzStorageAccount -ResourceGroupName "*" -Name $StorageAccountName -ErrorAction Stop).Context
	
	[hashtable]$cmdArgs = @{ 'Name' = $Name; 'Context' = $ctx; 'ErrorAction' = 'Stop' }
	if ($Quota) { $cmdArgs.Add('Quota', $Quota) }

	$share = New-AzStorageShare @cmdArgs
	Write-Output $share
} catch {
	Write-Error $_
	exit 1
}