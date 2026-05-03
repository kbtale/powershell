<#
.SYNOPSIS
	Azure: Gets storage usage
.DESCRIPTION
	Retrieves the current storage usage and limits for the current subscription.
.PARAMETER Location
	The Azure region to check usage for (optional).
.EXAMPLE
	PS> ./Get-StorageUsage.ps1 -Location "EastUS"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Location
)

try {
	Import-Module Az.Storage -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($Location) { $cmdArgs.Add('Location', $Location) }

	$usage = Get-AzStorageUsage @cmdArgs
	Write-Output $usage
} catch {
	Write-Error $_
	exit 1
}