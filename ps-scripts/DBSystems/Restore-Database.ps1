#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Restores a database from a backup or transaction log records

.DESCRIPTION
    Restores a database from a backup or transaction log records. This script allows for full, file, or log restoration with options for point-in-time recovery.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER DBName
    Specifies the name of the database to restore

.PARAMETER BackupFile
    Specifies the location and file name of the backup

.PARAMETER RestoreAction
    Specifies the type of backup operation to perform

.PARAMETER Checksum
    Indicates that a checksum value is calculated during the restore operation

.PARAMETER ClearSuspectPageTable
    Indicates that the suspect page table is deleted after the restore operation

.PARAMETER ContinueAfterError
    Indicates that the operation continues when a checksum error occurs. 
    If not set, the operation will fail after a checksum error

.PARAMETER DatabaseFile
    Specifies the database files targeted by the restore operation, comma separated. 
    This is only used when the RestoreAction parameter is set to File

.PARAMETER DatabaseFileGroup
    Specifies the database file groups targeted by the restore operation, comma separated. 
    This is only used when the RestoreAction parameter is set to File

.PARAMETER KeepReplication
    Indicates that the replication configuration is preserved

.PARAMETER NoRecovery
    Indicates that the database is restored into the restoring state

.PARAMETER ReplaceDatabase
    Indicates that a new image of the database is created. This overwrites any existing database with the same name. 
    If not set, the restore operation will fail when a database with that name already exists on the server.

.PARAMETER ToPointInTime
    Specifies the endpoint for database log restoration. This only applies when RestoreAction is set to Log

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Restore-Database.ps1 -ServerInstance "localhost\SQLEXPRESS" -DBName "TestDB" -BackupFile "C:\Backups\TestDB.bak" -ReplaceDatabase

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
        'Database' = $DBName
        'Confirm' = $false
        'RestoreAction' = $RestoreAction
        'CheckSum' = $CheckSum
        'ClearSuspectPageTable' = $ClearSuspectPageTable
        'ContinueAfterError' = $ContinueAfterError
        'BackupFile' = $BackupFile
        'KeepReplication' = $KeepReplication
        'ReplaceDatabase' = $ReplaceDatabase
        'NoRecovery' = $NoRecovery
        'PassThru' = $true
    }

    if ($RestoreAction -eq 'Files') {
        if (-not [string]::IsNullOrWhiteSpace($DatabaseFile)) {
            $cmdArgs.Add('DatabaseFile', $DatabaseFile.Split(','))
        } elseif (-not [string]::IsNullOrWhiteSpace($DatabaseFileGroup)) {
            $cmdArgs.Add('DatabaseFileGroup', $DatabaseFileGroup.Split(','))
        }
    } elseif ($RestoreAction -eq 'Log') {
        if ($null -ne $ToPointInTime) {
            $cmdArgs.Add('ToPointInTime', $ToPointInTime)
        }
    }

    $result = Restore-SqlDatabase @cmdArgs | Select-Object *    
    Write-Output $result
} catch {
    throw
}
