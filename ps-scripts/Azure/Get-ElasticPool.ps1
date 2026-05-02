<#
.SYNOPSIS
	Azure: Gets Azure SQL Elastic Pools
.DESCRIPTION
	Retrieves information about Azure SQL Elastic Pools on a specific server.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER ElasticPoolName
	The name of the Elastic Pool (optional).
.EXAMPLE
	PS> ./Get-ElasticPool.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName,

	[Parameter(Mandatory = $false)]
	[string]$ElasticPoolName
)

try {
	Import-Module Az.Sql -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ResourceGroupName' = $ResourceGroupName; 'ServerName' = $ServerName; 'ErrorAction' = 'Stop' }
	if ($ElasticPoolName) { $cmdArgs.Add('ElasticPoolName', $ElasticPoolName) }

	$pools = Get-AzSqlElasticPool @cmdArgs
	Write-Output $pools
} catch {
	Write-Error $_
	exit 1
}