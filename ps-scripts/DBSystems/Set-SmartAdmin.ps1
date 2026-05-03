#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Configures SQL Server Smart Admin settings

.DESCRIPTION
    Configures backup retention and storage settings for SQL Server Smart Admin (Managed Backup). This script allows enabling/disabling backups, setting retention periods, and managing the global Smart Admin master switch.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.
    
.PARAMETER DatabaseName
    Specifies the name of the database for which to configure Smart Admin settings

.PARAMETER BackupEnabled
    Indicates whether SQL Server Managed Backup to Windows Azure should be enabled

.PARAMETER BackupRetentionPeriodInDays
    Specifies the number of days the backup files should be retained

.PARAMETER MasterSwitch
    Indicates whether to pause or restart all services under Smart Admin

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Set-SmartAdmin.ps1 -ServerInstance "localhost\SQLEXPRESS" -BackupEnabled $true -BackupRetentionPeriodInDays 30

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$DatabaseName,
    [bool]$BackupEnabled,
    [int]$BackupRetentionPeriodInDays,
    [bool]$MasterSwitch,
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

    [hashtable]$getArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $instance
        'Confirm' = $false
    }    
    [hashtable]$setArgs = @{
        'ErrorAction' = 'Stop'
        'BackupEnabled' = $BackupEnabled
        'MasterSwitch' = $MasterSwitch
        'Confirm' = $false
    }
    if (-not [string]::IsNullOrWhiteSpace($DatabaseName)) {
        $getArgs.Add('DatabaseName', $DatabaseName)
    }
    if ($BackupRetentionPeriodInDays -gt 0) {
        $setArgs.Add('BackupRetentionPeriodInDays', $BackupRetentionPeriodInDays)
    }

    $smartAdmin = Get-SqlSmartAdmin @getArgs
    $result = $smartAdmin | Set-SqlSmartAdmin @setArgs | Select-Object *    
    Write-Output $result
} catch {
    throw
}
