<#
.SYNOPSIS
	Azure: Gets a summary report of SQL databases
.DESCRIPTION
	Retrieves a summarized list of Azure SQL databases on a specific server.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.EXAMPLE
	PS> ./Get-DatabaseSummaryReport.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer"
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
	$databases = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ErrorAction Stop | Select-Object DatabaseName, Status, Edition, ServiceObjectiveName, CreationDate
	Write-Output $databases
} catch {
	Write-Error $_
	exit 1
}