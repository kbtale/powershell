<#
.SYNOPSIS
	Azure: Gets Azure SQL databases
.DESCRIPTION
	Retrieves information about Azure SQL databases on a specific server or resource group.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER DatabaseName
	The name of the database (optional).
.EXAMPLE
	PS> ./Get-Database.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName,

	[Parameter(Mandatory = $false)]
	[string]$DatabaseName
)

try {
	Import-Module Az.Sql -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ResourceGroupName' = $ResourceGroupName; 'ServerName' = $ServerName; 'ErrorAction' = 'Stop' }
	if ($DatabaseName) { $cmdArgs.Add('DatabaseName', $DatabaseName) }

	$databases = Get-AzSqlDatabase @cmdArgs
	Write-Output $databases
} catch {
	Write-Error $_
	exit 1
}