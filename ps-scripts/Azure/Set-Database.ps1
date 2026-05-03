<#
.SYNOPSIS
	Azure: Updates an Azure SQL database
.DESCRIPTION
	Updates the configuration or performance tier of an existing Azure SQL database.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER DatabaseName
	The name of the database to update.
.PARAMETER Edition
	The edition of the database (e.g. Standard, Premium).
.PARAMETER ServiceObjectiveName
	The service level objective (e.g. S1, S2).
.EXAMPLE
	PS> ./Set-Database.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -DatabaseName "AppDB" -ServiceObjectiveName "S2"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName,

	[Parameter(Mandatory = $true)]
	[string]$DatabaseName,

	[Parameter(Mandatory = $false)]
	[string]$Edition,

	[Parameter(Mandatory = $false)]
	[string]$ServiceObjectiveName
)

try {
	Import-Module Az.Sql -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 
		'ResourceGroupName' = $ResourceGroupName; 
		'ServerName' = $ServerName; 
		'DatabaseName' = $DatabaseName;
		'ErrorAction' = 'Stop' 
	}
	if ($Edition) { $cmdArgs.Add('Edition', $Edition) }
	if ($ServiceObjectiveName) { $cmdArgs.Add('ServiceObjectiveName', $ServiceObjectiveName) }

	$db = Set-AzSqlDatabase @cmdArgs
	Write-Output $db
} catch {
	Write-Error $_
	exit 1
}