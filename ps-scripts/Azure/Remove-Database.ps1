<#
.SYNOPSIS
	Azure: Removes an Azure SQL database
.DESCRIPTION
	Deletes an existing Azure SQL database from a server.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER DatabaseName
	The name of the database to remove.
.EXAMPLE
	PS> ./Remove-Database.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -DatabaseName "OldDB"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName,

	[Parameter(Mandatory = $true)]
	[string]$DatabaseName
)

try {
	Import-Module Az.Sql -ErrorAction Stop
	Remove-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -DatabaseName $DatabaseName -Force -ErrorAction Stop
	Write-Output "Successfully removed database '$DatabaseName' from server '$ServerName'."
} catch {
	Write-Error $_
	exit 1
}