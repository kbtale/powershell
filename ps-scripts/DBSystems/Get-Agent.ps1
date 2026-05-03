#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Server Agent service information

.DESCRIPTION
    Retrieves information about the SQL Server Agent for a specified instance. This script provides details on the agent's state, service account, log level, and history settings, returning structured data for easy auditing.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Name,ServiceAccount. Use * for all properties

.EXAMPLE
    PS> ./Get-Agent.ps1 -ServerInstance "localhost\SQLEXPRESS" -Properties Name,State,ServiceAccount

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(  
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [int]$ConnectionTimeout = 30,
    [Validateset('*','Name','State','AgentLogLevel','ErrorLogFile','MaximumHistoryRows','ServiceAccount','ServiceStartMode','SqlAgentAutoStart')]
    [string[]]$Properties = @('Name','State','AgentLogLevel','ErrorLogFile','MaximumHistoryRows','ServiceAccount','ServiceStartMode','SqlAgentAutoStart')
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
    }      
    $result = Get-SqlAgent @cmdArgs | Select-Object $Properties
    
    Write-Output $result
} catch {
    throw
}
