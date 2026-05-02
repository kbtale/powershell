<#
.SYNOPSIS
	Azure: Creates a new Azure SQL database
.DESCRIPTION
	Creates a new Azure SQL database on a specified server with chosen performance characteristics.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER DatabaseName
	The name for the new database.
.PARAMETER Edition
	The edition of the database (e.g. Basic, Standard, Premium, GeneralPurpose).
.PARAMETER ComputeModel
	The compute model (e.g. Serverless, Provisioned).
.PARAMETER ServiceObjectiveName
	The service level objective (e.g. S0, S1, GP_S_Gen5_1).
.EXAMPLE
	PS> ./New-Database.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -DatabaseName "AppDB" -Edition "Standard" -ServiceObjectiveName "S1"
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
	[string]$ComputeModel,

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
	if ($ComputeModel) { $cmdArgs.Add('ComputeModel', $ComputeModel) }
	if ($ServiceObjectiveName) { $cmdArgs.Add('ServiceObjectiveName', $ServiceObjectiveName) }

	$db = New-AzSqlDatabase @cmdArgs
	Write-Output $db
} catch {
	Write-Error $_
	exit 1
}