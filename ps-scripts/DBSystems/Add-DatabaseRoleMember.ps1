#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Adds members to a specific database role

.DESCRIPTION
    Adds one or more members to a specified SQL Server database role. This script accepts a comma-separated list of members and returns the updated role status and membership as structured data.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER DBName
    Specifies the name of the database

.PARAMETER RoleName
    Specifies the name of the role    

.PARAMETER Members
    Specifies the names of the members to be added to the role, comma separated

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Add-DatabaseRoleMember.ps1 -ServerInstance "localhost\SQLEXPRESS" -DBName "TestDB" -RoleName "db_datareader" -Members "User1,User2"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]  
    [string]$DBName, 
    [Parameter(Mandatory = $true)]   
    [string]$RoleName,
    [Parameter(Mandatory = $true)]   
    [string]$Members,
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
    
    $role = $db.Roles | Where-Object { $_.Name -eq $RoleName }
    if ($null -eq $role) {
        throw "Database role '$RoleName' not found in database '$DBName'."
    }

    foreach ($item in $Members.Split(',')) {
        $cleanItem = $item.Trim()
        if (-not [string]::IsNullOrWhiteSpace($cleanItem)) {
            $role.AddMember($cleanItem)
        }
    }
    
    # Refresh and output
    $role.Refresh()
    $result = [PSCustomObject]@{
        Role     = $role.Name
        Database = $DBName
        Members  = $role.EnumMembers() -join ', '
    }

    Write-Output $result
} catch {
    throw
}
