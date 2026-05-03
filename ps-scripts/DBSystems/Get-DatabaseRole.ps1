#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets the roles and their members from a SQL database

.DESCRIPTION
    Retrieves a list of database roles and their associated members for a specified SQL Server database. This script returns structured data objects, making it ideal for reporting and automation.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER DBName
    Specifies the name of the database that gets the roles

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Get-DatabaseRole.ps1 -ServerInstance "localhost\SQLEXPRESS" -DBName "TestDB"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DBName,
    [pscredential]$ServerCredential,
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
    $db = Get-SqlDatabaseInternal -DatabaseName $DBName -ServerInstance $instance
    
    $roles = $db.Roles
    $result = foreach ($role in $roles) {
        $members = $role.EnumMembers()
        if ($null -eq $members -or $members.Count -eq 0) {
            [PSCustomObject]@{
                Role     = $role.Name
                Member   = $null
                Database = $DBName
            }
        } else {
            foreach ($member in $members) {
                [PSCustomObject]@{
                    Role     = $role.Name
                    Member   = $member
                    Database = $DBName
                }
            }
        }
    }

    Write-Output $result
} catch {
    throw
}
