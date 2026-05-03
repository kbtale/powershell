#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Writes data to a SQL Server table

.DESCRIPTION
    Inserts data into a specified SQL Server table. This script supports inserting a single row via parameters or multiple rows via a CSV file, providing a standardized way to populate tables.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DatabaseName
    Specifies the name of the database that contains the table

.PARAMETER TableName
    Specifies the name of the target table

.PARAMETER ColumnNames
    Specifies the names of the columns to populate, comma separated (e.g. "ID,Name,Description")

.PARAMETER Values
    Specifies the values to insert, comma separated (e.g. "1,John,Example")

.PARAMETER ValuesCsvFile
    Specifies the path to a CSV file containing the data to insert

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER SchemaName
    Specifies the name of the schema (defaults to 'dbo')

.PARAMETER Timeout
    Specifies a time-out value, in seconds, for the write operation

.PARAMETER CsvDelimiter
    Specifies the delimiter used in the CSV file (defaults to ';')

.PARAMETER FileEncoding
    Specifies the character encoding of the CSV file (defaults to 'UTF8')

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Write-TableData.ps1 -ServerInstance "localhost\SQLEXPRESS" -DatabaseName "SalesDB" -TableName "Logs" -ColumnNames "Msg,Level" -Values "Test,Info"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByString")]   
    [Parameter(Mandatory = $true, ParameterSetName = "ByCsv")]   
    [string]$ServerInstance,    

    [Parameter(Mandatory = $true, ParameterSetName = "ByString")]   
    [Parameter(Mandatory = $true, ParameterSetName = "ByCsv")]
    [string]$DatabaseName,

    [Parameter(Mandatory = $true, ParameterSetName = "ByString")]   
    [Parameter(Mandatory = $true, ParameterSetName = "ByCsv")] 
    [string]$TableName,

    [Parameter(Mandatory = $true, ParameterSetName = "ByString")]   
    [string]$ColumnNames,

    [Parameter(Mandatory = $true, ParameterSetName = "ByString")]   
    [string]$Values,           

    [Parameter(Mandatory = $true, ParameterSetName = "ByCsv")]   
    [string]$ValuesCsvFile,

    [Parameter(ParameterSetName = "ByString")]   
    [Parameter(ParameterSetName = "ByCsv")] 
    [pscredential]$ServerCredential,

    [Parameter(ParameterSetName = "ByString")]   
    [Parameter(ParameterSetName = "ByCsv")] 
    [string]$SchemaName = "dbo",

    [Parameter(ParameterSetName = "ByString")]   
    [Parameter(ParameterSetName = "ByCsv")] 
    [Int32]$Timeout,

    [Parameter(ParameterSetName = "ByCsv")] 
    [string]$CsvDelimiter = ';',

    [Parameter(ParameterSetName = "ByCsv")] 
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',

    [Parameter(ParameterSetName = "ByString")]   
    [Parameter(ParameterSetName = "ByCsv")] 
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try {
    [hashtable]$writeArgs = @{
        'ErrorAction' = 'Stop'
        'ServerInstance' = $ServerInstance
        'ConnectionTimeout' = $ConnectionTimeout
        'DatabaseName' = $DatabaseName
        'TableName' = $TableName
        'SchemaName' = $SchemaName
        'Force' = $true
    }              
    if ($Timeout -gt 0) {
        $writeArgs.Add('Timeout', $Timeout)
    } 
    if ($null -ne $ServerCredential) {
        $writeArgs.Add('Credential', $ServerCredential)
    }                

    [int]$rowCount = 0
    [string[]]$targetCols = @()

    if ($PSCmdlet.ParameterSetName -eq "ByString") {
        $cols = $ColumnNames.Split(',').Trim()
        $vals = $Values.Split(',').Trim()
        $targetCols = $cols
        
        $newRow = [ordered]@{}
        for ($i = 0; $i -lt $cols.Count; $i++) {
            $newRow.Add($cols[$i], $vals[$i])
        }
        
        [PSCustomObject]$newRow | Write-SqlTableData @writeArgs
        $rowCount = 1
    } else {
        if (-not (Test-Path -Path $ValuesCsvFile)) {
            throw "CSV file not found: $ValuesCsvFile"
        }
        
        $csvData = Import-Csv -Path $ValuesCsvFile -Delimiter $CsvDelimiter -Encoding $FileEncoding
        if ($csvData.Count -gt 0) {
            $targetCols = $csvData[0].psobject.Properties.Name
            $csvData | Write-SqlTableData @writeArgs
            $rowCount = $csvData.Count
        }
    }

    # Return the inserted rows (or recent rows) as confirmation
    [hashtable]$readArgs = @{
        'ErrorAction' = 'Stop'
        'ServerInstance' = $ServerInstance
        'ConnectionTimeout' = $ConnectionTimeout
        'DatabaseName' = $DatabaseName
        'TableName' = $TableName
        'SchemaName' = $SchemaName
        'ColumnOrderType' = 'DESC'
        'TopN' = $rowCount
    }
    if ($null -ne $ServerCredential) {
        $readArgs.Add('Credential', $ServerCredential)
    }
    if ($targetCols.Count -gt 0) {
        $readArgs.Add('ColumnOrder', $targetCols[0])
    }

    $result = Read-SqlTableData @readArgs
    Write-Output $result
} catch {
    throw
}
