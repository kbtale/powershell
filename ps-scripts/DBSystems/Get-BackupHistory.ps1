#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets backup history information for databases

.DESCRIPTION
    Retrieves backup history records from a SQL Server instance. Supports filtering by backup type, database name, and time range (including predefined periods like 'Yesterday' or 'LastWeek').

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER BackupType
    The type of backup to filter on. If not specified then gets all backup types

.PARAMETER DBName
    The names of the databases whose backup records are to be retrieved, comma separated

.PARAMETER EndTime
    The time before which all backup records to be retrieved should have completed

.PARAMETER IgnoreProviderContext
    Indicates that this cmdlet does not use the current context to override the values of the ServerInstance, DatabaseName parameters

.PARAMETER IncludeSnapshotBackups
    This switch will make the cmdlet obtain records for snapshot backups as well

.PARAMETER Since
    Specifies an abbreviation for the StartTime parameter

.PARAMETER StartTime
    Gets the backup records which started after this specified time

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Name,BackupFinishDate. Use * for all properties

.EXAMPLE
    PS> ./Get-BackupHistory.ps1 -ServerInstance "localhost\SQLEXPRESS" -Since Yesterday

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [ValidateSet('Database', 'Differential', 'Incremental', 'Log', 'FileOrFileGroup', 'FileOrFileGroupDifferential')]
    [string]$BackupType,
    [string]$DBName,
    [datetime]$EndTime,
    [datetime]$StartTime,
    [switch]$IgnoreProviderContext,
    [switch]$IncludeSnapshotBackups,
    [switch]$SuppressProviderContextWarning,
    [ValidateSet('Midnight', 'Yesterday', 'LastWeek', 'LastMonth')]
    [string]$Since,
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','DatabaseName','BackupSetId','BackupStartDate','BackupFinishDate','BackupSize','Type','UserName','ServerName','Description')]
    [string[]]$Properties = @('DatabaseName','BackupStartDate','BackupFinishDate','BackupSize','Type','UserName')
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
    if ($Properties -contains '*') {
        $Properties = @('*')
    }
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $instance
        'IgnoreProviderContext' = $IgnoreProviderContext
        'IncludeSnapshotBackups' = $IncludeSnapshotBackups
        'SuppressProviderContextWarning' = $SuppressProviderContextWarning
    }
    
    if (-not [string]::IsNullOrWhiteSpace($DBName)) {
        $cmdArgs.Add("DatabaseName", $DBName)
    }
    if (-not [string]::IsNullOrWhiteSpace($BackupType)) {
        $cmdArgs.Add("BackupType", $BackupType)
    }
    if ($null -ne $EndTime) {
        $cmdArgs.Add('EndTime', $EndTime)
    }
    if ($null -ne $StartTime) {
        $cmdArgs.Add('StartTime', $StartTime)
    }
    if ($null -eq $StartTime -and -not [string]::IsNullOrWhiteSpace($Since)) {
        $cmdArgs.Add("Since", $Since)
    }
    
    $result = Get-SqlBackupHistory @cmdArgs | Select-Object $Properties
    Write-Output $result
} catch {
    throw
}
