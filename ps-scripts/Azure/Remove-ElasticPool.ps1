<#
.SYNOPSIS
	Azure: Removes an Azure SQL Elastic Pool
.DESCRIPTION
	Deletes an existing Azure SQL Elastic Pool from a server.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER ElasticPoolName
	The name of the Elastic Pool to remove.
.EXAMPLE
	PS> ./Remove-ElasticPool.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -ElasticPoolName "OldPool"
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
	Remove-AzSqlElasticPool -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ElasticPoolName $ElasticPoolName -Force -ErrorAction Stop
	Write-Output "Successfully removed Elastic Pool '$ElasticPoolName' from server '$ServerName'."
} catch {
	Write-Error $_
	exit 1
}