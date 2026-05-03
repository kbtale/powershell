#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Reads data from a SQL Server table or view

.DESCRIPTION
    Retrieves records from a specified SQL Server table or view. This script allows for column selection, sorting, and limiting the number of rows returned, providing a standardized way to query data from the command line.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DatabaseName
    Specifies the name of the database that contains the table or view

.PARAMETER TableName
    Specifies the name of the table to read (ParameterSetName: Table)

.PARAMETER ViewName
    Specifies the name of the view to read (ParameterSetName: View)

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER SchemaName
    Specifies the name of the schema (defaults to 'dbo')

.PARAMETER ColumnNames
    Specifies the names of columns to return, comma separated

.PARAMETER ColumnOrder
    Specifies the names of columns by which to sort the results, comma separated

.PARAMETER ColumnOrderType
    Specifies the sort order (ASC or DESC)

.PARAMETER NumberOfRows 
    Specifies the maximum number of rows to return

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Read-Data.ps1 -ServerInstance "localhost\SQLEXPRESS" -DatabaseName "SalesDB" -TableName "Orders" -NumberOfRows 10

.CATEGORY DBSystems
#>

[CmdLetBinding(DefaultParameterSetName = "Table")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Table")]   
    [Parameter(Mandatory = $true, ParameterSetName = "View")]   
    [string]$ServerInstance,    

    [Parameter(Mandatory = $true, ParameterSetName = "Table")]   
    [Parameter(Mandatory = $true, ParameterSetName = "View")]   
    [string]$DatabaseName,

    [Parameter(Mandatory = $true, ParameterSetName = "Table")]       
    [string]$TableName,

    [Parameter(Mandatory = $true, ParameterSetName = "View")]   
    [string]$ViewName,

    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [pscredential]$ServerCredential,

    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [string]$SchemaName = "dbo",

    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [string]$ColumnNames,

    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [string]$ColumnOrder,

    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [Int64]$NumberOfRows,

    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [ValidateSet('ASC','DESC')]
    [string]$ColumnOrderType = "ASC",

    [Parameter(ParameterSetName = "Table")]   
    [Parameter(ParameterSetName = "View")] 
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try {
    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'ServerInstance' = $ServerInstance
        'ConnectionTimeout' = $ConnectionTimeout
        'DatabaseName' = $DatabaseName
        'SchemaName' = $SchemaName
        'ColumnOrderType' = $ColumnOrderType
    }     
    
    if (-not [string]::IsNullOrWhiteSpace($ColumnNames)) {
        $cmdArgs.Add('ColumnName', $ColumnNames.Split(',').Trim())
    } 
    if (-not [string]::IsNullOrWhiteSpace($ColumnOrder)) {
        $cmdArgs.Add('ColumnOrder', $ColumnOrder.Split(',').Trim())
    }      
    if ($NumberOfRows -gt 0) {
        $cmdArgs.Add('TopN', $NumberOfRows)
    } 
    if ($null -ne $ServerCredential) {
        $cmdArgs.Add('Credential', $ServerCredential)
    }            

    if ($PSCmdlet.ParameterSetName -eq 'Table') {
        $cmdArgs.Add('TableName', $TableName)
        $result = Read-SqlTableData @cmdArgs
    } else {
        $cmdArgs.Add('ViewName', $ViewName)
        $result = Read-SqlViewData @cmdArgs
    }
    
    Write-Output $result
} catch {
    throw
}
