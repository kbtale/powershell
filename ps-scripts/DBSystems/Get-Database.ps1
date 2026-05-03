#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL database objects for each database in the target SQL Server instance

.DESCRIPTION
    Retrieves information about SQL Server databases. You can specify a single database name or list all databases, with customizable property selection for reporting and monitoring.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER DBName
    Specifies the name of the database that this cmdlet gets the SQL database object

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Name,Status. Use * for all properties

.EXAMPLE
    PS> ./Get-Database.ps1 -ServerInstance "localhost\SQLEXPRESS" -Properties Name,Status,Size

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$DBName,
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','Name','Status','Size','SpaceAvailable','Owner','LastBackupDate','LastLogBackupDate','IsUpdateable','DefaultFileGroup','AutoShrink','ActiveConnections')]
    [string[]]$Properties = @('Name','Status','Size','SpaceAvailable','Owner','LastBackupDate','LastLogBackupDate','IsUpdateable','DefaultFileGroup','AutoShrink','ActiveConnections')
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
        'Confirm' = $false
    }
    
    if (-not [string]::IsNullOrWhiteSpace($DBName)) {
        $cmdArgs.Add("Name", $DBName)
    }
    
    $result = Get-SqlDatabase @cmdArgs | Select-Object $Properties
    Write-Output $result
} catch {
    throw
}
