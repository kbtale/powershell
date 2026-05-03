#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Server instance-level roles and their members

.DESCRIPTION
    Retrieves a list of server-level roles (instance roles) and their associated members for a specified SQL Server instance. This script returns structured data objects, making it ideal for security auditing and automation.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Get-InstanceRole.ps1 -ServerInstance "localhost\SQLEXPRESS"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance, 
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

Import-Module SQLServer

try {
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout
        
    $roles = $instance.Roles
    $result = foreach ($role in $roles) {
        $members = $role.EnumMemberNames()
        if ($null -eq $members -or $members.Count -eq 0) {
            [PSCustomObject]@{
                Role     = $role.Name
                Member   = $null
                Instance = $ServerInstance
            }
        } else {
            foreach ($member in $members) {
                [PSCustomObject]@{
                    Role     = $role.Name
                    Member   = $member
                    Instance = $ServerInstance
                }
            }
        }
    }

    Write-Output $result
} catch {
    throw
}
