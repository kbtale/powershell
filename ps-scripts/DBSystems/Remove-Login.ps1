#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Removes a Login from a SQL Server instance

.DESCRIPTION
    Removes a SQL Server login. Includes an option to also remove associated database users, providing a clean way to decommission access.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER LoginName
    Specifies the name of Login object that this cmdlet removes. Supports wildcards.

.PARAMETER RemoveAssociatedUser
    Indicates that this cmdlet removes the users that are associated with the Login object

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Remove-Login.ps1 -ServerInstance "localhost\SQLEXPRESS" -LoginName "OldUser" -RemoveAssociatedUser

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$LoginName,   
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [switch]$RemoveAssociatedUser,
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
    
    if (-not [string]::IsNullOrWhiteSpace($LoginName)) {
        $searchName = $LoginName
        if (-not $searchName.StartsWith('*')) { $searchName = '*' + $searchName }
        if (-not $searchName.EndsWith('*')) { $searchName += '*' }
        
        [hashtable]$getArgs = @{
            'ErrorAction' = 'Stop'
            'InputObject' = $instance
            'LoginName' = $searchName
            'Wildcard' = $null
        }
        $sqllogin = Get-SqlLogin @getArgs

        [hashtable]$removeArgs = @{
            'ErrorAction' = 'Stop'
            'InputObject' = $sqllogin
            'RemoveAssociatedUsers' = $RemoveAssociatedUser
            'Confirm' = $false
            'Force' = $true
        }       
        Remove-SqlLogin @removeArgs
        
        Write-Output "Login $($LoginName) successfully removed."
    }
} catch {
    throw
}
