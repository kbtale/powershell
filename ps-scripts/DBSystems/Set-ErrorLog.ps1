#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Sets the maximum number of SQL Server error log files

.DESCRIPTION
    Configures the maximum number of error log files (between 6 and 99) before they are recycled on a SQL Server instance. This script provides a standardized way to manage log retention settings and returns the current log entries after the update.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER MaxLogCount
    Specifies the maximum number of error log files to retain (Valid range: 6 to 99)

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Set-ErrorLog.ps1 -ServerInstance "localhost\SQLEXPRESS" -MaxLogCount 10

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [ValidateRange(6,99)]
    [int]$MaxLogCount,
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
    [string[]]$Properties = @('Date', 'Source', 'Text', 'ServerInstance')
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $instance
        'MaxLogCount' = $MaxLogCount
    }     
    Set-SqlErrorLog @cmdArgs                            
    
    # Return recent logs as confirmation
    $result = Get-SqlErrorLog -InputObject $instance -ErrorAction Stop | Select-Object -First 10 $Properties
    Write-Output $result
} catch {
    throw
}
