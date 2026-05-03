#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Server database column encryption key objects

.DESCRIPTION
    Retrieves information about column encryption keys (CEK) defined within a SQL Server database. This script provides a standardized way to audit encryption metadata, returning structured data objects for each key.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER DatabaseName 
    Specifies the name of the SQL database to query

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER KeyName
    Specifies the name of a specific column encryption key to retrieve

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Get-ColumnEncryptionKey.ps1 -ServerInstance "localhost\SQLEXPRESS" -DatabaseName "SalesDB"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,    
    [pscredential]$ServerCredential,
    [string]$KeyName,
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
        'ErrorAction' = 'Stop'
        'InputObject' = $db
    }
    if (-not [string]::IsNullOrWhiteSpace($KeyName)) {
        $cmdArgs.Add("Name", $KeyName)
    }

    $result = Get-SqlColumnEncryptionKey @cmdArgs | Select-Object *
    Write-Output $result
} catch {
    throw
}
