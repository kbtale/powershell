<#
.SYNOPSIS
	Azure: Renames an Azure SQL database
.DESCRIPTION
	Changes the name of an existing Azure SQL database.
.PARAMETER ResourceGroupName
	The name of the resource group.
.PARAMETER ServerName
	The name of the Azure SQL Server.
.PARAMETER DatabaseName
	The current name of the database.
.PARAMETER NewName
	The new name for the database.
.EXAMPLE
	PS> ./Rename-Database.ps1 -ResourceGroupName "MyRG" -ServerName "MyServer" -DatabaseName "OldName" -NewName "NewName"
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory = $true)]
	[string]$ServerName,

	[Parameter(Mandatory = $true)]
	[string]$DatabaseName,

	[Parameter(Mandatory = $true)]
	[string]$NewName
)

try {
	Import-Module Az.Sql -ErrorAction Stop
	Set-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -DatabaseName $DatabaseName -NewName $NewName -ErrorAction Stop | Out-Null
	Write-Output "Successfully renamed database from '$DatabaseName' to '$NewName'."
} catch {
	Write-Error $_
	exit 1
}