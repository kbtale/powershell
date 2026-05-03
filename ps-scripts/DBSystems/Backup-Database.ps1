#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Performs a backup of a SQL Server database

.DESCRIPTION
    Executes a backup operation for a specified SQL Server database. This script supports full, differential (incremental), and transaction log backups, with options for compression, checksums, and file-level targeting.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DBName
    Specifies the name of the database to back up

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER BackupAction
    Specifies the type of backup operation to perform: Database (Full), Files, or Log

.PARAMETER BackupFile
    Specifies the location and file name for the backup (e.g. C:\Backups\MyDatabase.bak)

.PARAMETER BackupContainer
    Specifies the folder or location where the cmdlet stores backups

.PARAMETER BackupSetName
    Specifies the name of the backup set

.PARAMETER BackupSetDescription
    Specifies the description of the backup set

.PARAMETER BlockSize
    Specifies the physical block size for the backup in bytes

.PARAMETER CheckSum
    Indicates that a checksum value is calculated during the backup operation

.PARAMETER ContinueAfterError
    Indicates that the operation continues when a checksum error occurs

.PARAMETER CopyOnly
    Indicates that the backup is a copy-only backup

.PARAMETER CompressionOption
    Specifies the compression options for the backup operation (Default, On, or Off)

.PARAMETER DatabaseFile
    Specifies one or more database files to back up, comma separated. Only used when BackupAction is 'Files'.

.PARAMETER DatabaseFileGroup
    Specifies the database file groups to back up, comma separated. Only used when BackupAction is 'Files'.

.PARAMETER Incremental
    Indicates that a differential backup should be performed

.PARAMETER LogTruncationType
    Specifies the truncation behavior for log backups (TruncateOnly, Truncate, or NoTruncate)

.PARAMETER NoRecovery
    Indicates that the tail end of the log is not backed up

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Backup-Database.ps1 -ServerInstance "localhost\SQLEXPRESS" -DBName "SalesDB" -BackupFile "C:\Backups\SalesDB.bak"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DBName,
    [pscredential]$ServerCredential,    
    [ValidateSet('Database', 'Files', 'Log')]
    [string]$BackupAction = "Database",
    [string]$BackupFile,
    [string]$BackupContainer,
    [string]$BackupSetName,
    [string]$BackupSetDescription,     
    [ValidateSet('512', '1024', '2048', '4096', '8192', '16384','32768','65536')]
    [string]$BlockSize = "512",
    [switch]$CheckSum,
    [switch]$ContinueAfterError,
    [switch]$CopyOnly,
    [ValidateSet('Default','On','Off')]
    [string]$CompressionOption = "Default",
    [string]$DatabaseFile,
    [string]$DatabaseFileGroup,
    [switch]$Incremental,
    [ValidateSet('TruncateOnly','Truncate','NoTruncate')]
    [string]$LogTruncationType = "Truncate",
    [switch]$NoRecovery,
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
        'BackupAction' = $BackupAction
        'BlockSize'   = [int]$BlockSize
        'CheckSum'    = $CheckSum
        'CompressionOption' = $CompressionOption
        'ContinueAfterError' = $ContinueAfterError
        'CopyOnly'    = $CopyOnly
        'Incremental' = $Incremental
        'LogTruncationType' = $LogTruncationType
        'NoRecovery'  = $NoRecovery
        'PassThru'    = $true
    }
    
    if (-not [string]::IsNullOrWhiteSpace($BackupFile)) {
        $cmdArgs.Add('BackupFile', $BackupFile)
    }
    elseif (-not [string]::IsNullOrWhiteSpace($BackupContainer)) {
        $cmdArgs.Add('BackupContainer', $BackupContainer)
    }
    
    if (-not [string]::IsNullOrWhiteSpace($BackupSetName)) {
        $cmdArgs.Add('BackupSetName', $BackupSetName)
    }
    if (-not [string]::IsNullOrWhiteSpace($BackupSetDescription)) {
        $cmdArgs.Add('BackupSetDescription', $BackupSetDescription)
    }
    
    if ($BackupAction -eq 'Files') {
        if (-not [string]::IsNullOrWhiteSpace($DatabaseFile)) {
            $cmdArgs.Add('DatabaseFile', $DatabaseFile.Split(',').Trim())
        }
        elseif (-not [string]::IsNullOrWhiteSpace($DatabaseFileGroup)) {
            $cmdArgs.Add('DatabaseFileGroup', $DatabaseFileGroup.Split(',').Trim())
        }
    }
   
    $result = Backup-SqlDatabase @cmdArgs | Select-Object *    
    Write-Output $result
} catch {
    throw
}
