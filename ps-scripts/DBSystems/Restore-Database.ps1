#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Restores a SQL Server database from a backup

.DESCRIPTION
    Restores a SQL Server database from a backup file. This script supports full database, file-level, and transaction log restorations, with options for point-in-time recovery, database replacement, and recovery state management.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DBName
    Specifies the name of the database to restore

.PARAMETER BackupFile
    Specifies the location and file name of the backup file to restore from

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER RestoreAction
    Specifies the type of restoration operation: Database, Files, Log, OnlinePage, or OnlineFiles

.PARAMETER CheckSum
    Indicates that a checksum value is calculated during the restore operation

.PARAMETER ClearSuspectPageTable
    Indicates that the suspect page table is deleted after the restore operation

.PARAMETER ContinueAfterError
    Indicates that the operation continues when a checksum error occurs

.PARAMETER DatabaseFile
    Specifies specific database files to restore, comma separated. Only used when RestoreAction is 'Files'.

.PARAMETER DatabaseFileGroup
    Specifies specific database file groups to restore, comma separated. Only used when RestoreAction is 'Files'.

.PARAMETER KeepReplication
    Indicates that the replication configuration is preserved during restore

.PARAMETER NoRecovery
    Indicates that the database is left in the restoring state (NORECOVERY)

.PARAMETER ReplaceDatabase
    Indicates that any existing database with the same name should be overwritten (WITH REPLACE)

.PARAMETER ToPointInTime
    Specifies the endpoint for database log restoration (Point-in-time recovery)

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Restore-Database.ps1 -ServerInstance "localhost\SQLEXPRESS" -DBName "SalesDB" -BackupFile "C:\Backups\SalesDB.bak" -ReplaceDatabase

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DBName,
    [Parameter(Mandatory = $true)]   
    [string]$BackupFile,
    [pscredential]$ServerCredential,
    [ValidateSet('Database', 'Files', 'Log',  'OnlinePage', 'OnlineFiles')]
    [string]$RestoreAction = "Database",
    [switch]$CheckSum,
    [switch]$ClearSuspectPageTable,
    [switch]$ContinueAfterError,
    [string]$DatabaseFile,
    [string]$DatabaseFileGroup,
    [switch]$KeepReplication,
    [switch]$NoRecovery,
    [switch]$ReplaceDatabase,
    [datetime]$ToPointInTime,
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

Import-Module SQLServer

try {    
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $instance
        'Database'    = $DBName
        'Confirm'     = $false
        'RestoreAction' = $RestoreAction
        'CheckSum'    = $CheckSum
        'ClearSuspectPageTable' = $ClearSuspectPageTable
        'ContinueAfterError' = $ContinueAfterError
        'BackupFile'  = $BackupFile
        'KeepReplication' = $KeepReplication
        'ReplaceDatabase' = $ReplaceDatabase
        'NoRecovery'  = $NoRecovery
        'PassThru'    = $true
    }

    if ($RestoreAction -eq 'Files') {
        if (-not [string]::IsNullOrWhiteSpace($DatabaseFile)) {
            $cmdArgs.Add('DatabaseFile', $DatabaseFile.Split(',').Trim())
        }
        elseif (-not [string]::IsNullOrWhiteSpace($DatabaseFileGroup)) {
            $cmdArgs.Add('DatabaseFileGroup', $DatabaseFileGroup.Split(',').Trim())
        }
    }
    elseif ($RestoreAction -eq 'Log') {
        if ($null -ne $ToPointInTime) {
            $cmdArgs.Add('ToPointInTime', $ToPointInTime)
        }
    }

    $result = Restore-SqlDatabase @cmdArgs | Select-Object *    
    Write-Output $result
} catch {
    throw
}
