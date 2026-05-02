<#
.SYNOPSIS
	Azure: Gets Azure storage accounts
.DESCRIPTION
	Retrieves information about Azure storage accounts in the subscription or a specific resource group.
.PARAMETER ResourceGroupName
	The name of the resource group (optional).
.PARAMETER Name
	The name of the storage account (optional).
.EXAMPLE
	PS> ./Get-StorageAccount.ps1 -ResourceGroupName "MyRG"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $false)]
	[string]$Name
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($ResourceGroupName) { $cmdArgs.Add('ResourceGroupName', $ResourceGroupName) }
	if ($Name) { $cmdArgs.Add('Name', $Name) }

	$accounts = Get-AzStorageAccount @cmdArgs
	Write-Output $accounts
} catch {
	Write-Error $_
	exit 1
}