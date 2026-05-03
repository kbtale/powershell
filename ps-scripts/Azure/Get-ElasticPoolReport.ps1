<#
.SYNOPSIS
	Azure: Gets a report of Elastic Pools
.DESCRIPTION
	Retrieves a summary list of Azure SQL Elastic Pools on a specific server.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.EXAMPLE
	PS> ./Get-ElasticPoolReport.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer"
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
	$pools = Get-AzSqlElasticPool -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ErrorAction Stop | Select-Object ElasticPoolName, Edition, Dtu, State
	Write-Output $pools
} catch {
	Write-Error $_
	exit 1
}