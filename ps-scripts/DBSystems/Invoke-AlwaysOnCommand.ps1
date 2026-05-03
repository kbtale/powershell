#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Enables or disables the Always On availability groups feature for a server

.DESCRIPTION
    Enables or disables the Always On availability groups feature for a SQL Server instance. This script provides a way to manage the Always On feature state, with options for service restart management and credential handling.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER CommandCredential
    Credential to execute the command

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER Command
    Action to perform: Enable or Disable the Always On availability groups feature

.PARAMETER NoServiceRestart
    Indicates that the user is not prompted to restart the SQL Server service

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Invoke-AlwaysOnCommand.ps1 -ServerInstance "localhost\SQLEXPRESS" -Command "Enable" -NoServiceRestart

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential, 
    [pscredential]$CommandCredential,  
    [ValidateSet("Enable","Disable")]   
    [string]$Command ="Enable",          
    [switch]$NoServiceRestart,
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
        'NoServiceRestart' = $NoServiceRestart
        'Force' = $null
        'Confirm' = $false
    }      
                            
    if ($null -ne $CommandCredential) {
        $cmdArgs.Add('Credential', $CommandCredential)
    }                        
    
    if ($Command -eq "Enable") {
        Enable-SqlAlwaysOn @cmdArgs
    } else {
        Disable-SqlAlwaysOn @cmdArgs
    }  
    
    $result = Get-SqlInstance -InputObject $instance | Select-Object $Properties
    Write-Output $result
} catch {
    throw
}
