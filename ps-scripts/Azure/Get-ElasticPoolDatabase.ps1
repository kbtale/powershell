<#
.SYNOPSIS
	Azure: Gets databases in an Azure SQL Elastic Pool
.DESCRIPTION
	Retrieves the list of databases contained within a specific Azure SQL Elastic Pool.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER ElasticPoolName
	The name of the Elastic Pool.
.EXAMPLE
	PS> ./Get-ElasticPoolDatabase.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -ElasticPoolName "MyPool"
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
	$databases = Get-AzSqlElasticPoolDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ElasticPoolName $ElasticPoolName -ErrorAction Stop
	Write-Output $databases
} catch {
	Write-Error $_
	exit 1
}