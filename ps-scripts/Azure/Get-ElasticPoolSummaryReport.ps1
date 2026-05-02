<#
.SYNOPSIS
	Azure: Gets a summary report of Elastic Pools
.DESCRIPTION
	Retrieves a summarized list of Azure SQL Elastic Pools on a specific server.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.EXAMPLE
	PS> ./Get-ElasticPoolSummaryReport.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName
)

try {
	Import-Module Az.Sql -ErrorAction Stop
	$pools = Get-AzSqlElasticPool -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ErrorAction Stop | Select-Object ElasticPoolName, State, Edition, Dtu, DatabaseDtuMax
	Write-Output $pools
} catch {
	Write-Error $_
	exit 1
}