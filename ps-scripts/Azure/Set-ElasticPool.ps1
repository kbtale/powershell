<#
.SYNOPSIS
	Azure: Updates an Azure SQL Elastic Pool
.DESCRIPTION
	Updates the configuration or performance tier of an existing Azure SQL Elastic Pool.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER ElasticPoolName
	The name of the Elastic Pool to update.
.PARAMETER Edition
	The edition of the pool (e.g. Basic, Standard, Premium).
.PARAMETER Dtu
	The DTU limit for the pool.
.EXAMPLE
	PS> ./Set-ElasticPool.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -ElasticPoolName "MyPool" -Dtu 100
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName,

	[Parameter(Mandatory = $true)]
	[string]$ElasticPoolName,

	[Parameter(Mandatory = $false)]
	[string]$Edition,

	[Parameter(Mandatory = $false)]
	[int]$Dtu
)

try {
	Import-Module Az.Sql -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 
		'ResourceGroupName' = $ResourceGroupName; 
		'ServerName' = $ServerName; 
		'ElasticPoolName' = $ElasticPoolName;
		'ErrorAction' = 'Stop' 
	}
	if ($Edition) { $cmdArgs.Add('Edition', $Edition) }
	if ($Dtu) { $cmdArgs.Add('Dtu', $Dtu) }

	$pool = Set-AzSqlElasticPool @cmdArgs
	Write-Output $pool
} catch {
	Write-Error $_
	exit 1
}