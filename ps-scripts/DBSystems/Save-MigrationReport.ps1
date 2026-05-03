#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Generates a SQL Server In-Memory OLTP Migration Checklist

.DESCRIPTION
    Generates a migration report for transition to In-Memory OLTP for a specified database. This script provides a standardized way to evaluate database objects for compatibility and saves the resulting report to a specified folder.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DatabaseName
    Specifies the name of the database for which to generate the migration report

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER FolderPath
    Specifies the destination folder where the report files will be saved

.PARAMETER MigrationType
    Specifies the type of migration evaluation (Currently only 'OLTP' is supported)

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Save-MigrationReport.ps1 -ServerInstance "localhost\SQLEXPRESS" -DatabaseName "SalesDB" -FolderPath "C:\Reports\Migration"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,    
    [pscredential]$ServerCredential,
    [string]$FolderPath,
    [ValidateSet('OLTP')]
    [string]$MigrationType = 'OLTP',
    [int]$ConnectionTimeout = 30
)

function Get-SqlServerInstanceInternal {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]   
        [string]$ServerInstance,    
        [pscredential]$ServerCredential,
        [int]$ConnectionTimeout = 30
    )
    try {
        [hashtable]$cmdArgs = @{
            'ErrorAction' = 'Stop'
            'Confirm' = $false
            'ServerInstance' = $ServerInstance
            'ConnectionTimeout' = $ConnectionTimeout
        }
        if ($null -ne $ServerCredential) {
            $cmdArgs.Add('Credential', $ServerCredential)
        }
        return Get-SqlInstance @cmdArgs
    } catch {
        throw
    }
}

function Get-SqlDatabaseInternal {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]   
        [object]$ServerInstance,    
        [Parameter(Mandatory = $true)]   
        [string]$DatabaseName
    )
    try {
        [hashtable]$cmdArgs = @{
            'ErrorAction' = 'Stop'
            'InputObject' = $ServerInstance
            'Name' = $DatabaseName
            'Confirm' = $false
        }
        return Get-SqlDatabase @cmdArgs
    } catch {
        throw
    }
}

Import-Module SQLServer

try {
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout
    $db = Get-SqlDatabaseInternal -DatabaseName $DatabaseName -ServerInstance $instance
    
    [hashtable]$cmdArgs = @{
        'ErrorAction'   = 'Stop'
        'InputObject'   = $db
        'MigrationType' = $MigrationType
    }                                     
    if (-not [string]::IsNullOrWhiteSpace($FolderPath)) {
        if (-not (Test-Path -Path $FolderPath)) {
            New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
        }
        $cmdArgs.Add('FolderPath', $FolderPath)
    }
    
    $result = Save-SqlMigrationReport @cmdArgs
    Write-Output $result
} catch {
    throw
}
