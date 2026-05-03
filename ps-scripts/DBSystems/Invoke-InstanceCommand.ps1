#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Starts or stops a SQL Server Instance

.DESCRIPTION
    Starts or stops a SQL Server Instance. This script provides a way to manage the state of a SQL Server instance remotely using standard SQLServer module cmdlets.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER Command
    The action to perform: Start or Stop the SQL Instance

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Invoke-InstanceCommand.ps1 -ServerInstance "localhost\SQLEXPRESS" -Command "Stop"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [pscredential]$ServerCredential,  
    [ValidateSet("Start","Stop")]   
    [string]$Command ="Start",          
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
    $Properties = @('DisplayNameOrName','Status','Edition','InstanceName','DomainInstanceName','LoginMode','ServerType','ServiceStartMode','ComputerNamePhysicalNetBIOS')
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout
    
    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $instance
        'Credential' = $ServerCredential
        'Confirm' = $false
    }                            
    
    if ($Command -eq "Stop") {
        Stop-SqlInstance @cmdArgs
    } else {
        Start-SqlInstance @cmdArgs
    }  

    # Refresh and show status
    $getArgs = @{
        'ErrorAction' = 'Stop'
        'Confirm' = $false
        'Credential' = $ServerCredential
        'ServerInstance' = $ServerInstance
        'ConnectionTimeout' = $ConnectionTimeout
    }

    $result = Get-SqlInstance @getArgs | Select-Object $Properties
    Write-Output $result
} catch {
    throw
}
