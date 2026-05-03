#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Agent Job objects from a SQL Server instance

.DESCRIPTION
    Retrieves information about SQL Server Agent jobs. This script allows you to monitor job status, last run duration, and other critical execution metrics.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER JobName
    Specifies the name of the Job object that this cmdlet gets

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Name,State. Use * for all properties

.EXAMPLE
    PS> ./Get-AgentJob.ps1 -ServerInstance "localhost\SQLEXPRESS" -Properties Name,State,CurrentRunStatus

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(  
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$JobName,
    [int]$ConnectionTimeout = 30,
    [Validateset('*','Name','State','LastRunDuration','CurrentRunStatus','DateLastModified','Description','EmailLevel','EventLogLevel','OwnerLoginName')]
    [string[]]$Properties = @('Name','State','LastRunDuration','CurrentRunStatus','DateLastModified','Description','EmailLevel','EventLogLevel','OwnerLoginName')
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

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}      
    if (-not [string]::IsNullOrWhiteSpace($JobName)) {
        $cmdArgs.Add('Name', $JobName)
    }
    
    $result = Get-SqlAgent -InputObject $instance -ErrorAction Stop | Get-SqlAgentJob @cmdArgs | Select-Object $Properties
    Write-Output $result
} catch {
    throw
}
