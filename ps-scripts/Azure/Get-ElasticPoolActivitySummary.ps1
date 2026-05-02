<#
.SYNOPSIS
	Azure: Gets a summary of Elastic Pool activity
.DESCRIPTION
	Retrieves a summarized operation history for an Azure SQL Elastic Pool.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER ElasticPoolName
	The name of the Elastic Pool.
.EXAMPLE
	PS> ./Get-ElasticPoolActivitySummary.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -ElasticPoolName "MyPool"
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
	$activity = Get-AzSqlElasticPoolActivity -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ElasticPoolName $ElasticPoolName -ErrorAction Stop | Select-Object Operation, State, StartTime, EndTime, PercentComplete
	Write-Output $activity
} catch {
	Write-Error $_
	exit 1
}