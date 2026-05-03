#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Removes members from a specific SQL Server instance-level role

.DESCRIPTION
    Removes one or more members from a specified server-level role (instance role). This script accepts a comma-separated list of members and returns the updated membership status as structured data.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER RoleName
    Specifies the name of the instance-level role (e.g., sysadmin, securityadmin)

.PARAMETER Members
    Specifies the names of the members to be removed from the role, comma separated

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Remove-InstanceRoleMember.ps1 -ServerInstance "localhost\SQLEXPRESS" -RoleName "sysadmin" -Members "CONTOSO\User1"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,   
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

Import-Module SQLServer

try {
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout
   
    $role = $instance.Roles | Where-Object { $_.Name -eq $RoleName }
    if ($null -eq $role) {
        throw "Instance role '$RoleName' not found on server '$ServerInstance'."
    }

    foreach ($item in $Members.Split(',')) {
        $cleanItem = $item.Trim()
        if (-not [string]::IsNullOrWhiteSpace($cleanItem)) {
            $role.DropMember($cleanItem)
        }
    }
    
    # Refresh and output
    $role.Refresh()
    $result = [PSCustomObject]@{
        Role     = $role.Name
        Instance = $ServerInstance
        Members  = $role.EnumMemberNames() -join ', '
    }

    Write-Output $result
} catch {
    throw
}
