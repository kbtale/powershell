<#
.SYNOPSIS
	Azure: Gets a summary of databases in an Elastic Pool
.DESCRIPTION
	Retrieves a summarized list of databases within a specific Azure SQL Elastic Pool.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER ElasticPoolName
	The name of the Elastic Pool.
.EXAMPLE
	PS> ./Get-ElasticPoolDatabaseSummary.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -ElasticPoolName "MyPool"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName,

	[Parameter(Mandatory = $true)]
	[string]$ElasticPoolName
)

try {
	Import-Module Az.Sql -ErrorAction Stop
	$databases = Get-AzSqlElasticPoolDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ElasticPoolName $ElasticPoolName -ErrorAction Stop | Select-Object DatabaseName, Status, Edition, ServiceObjectiveName
	Write-Output $databases
} catch {
	Write-Error $_
	exit 1
}