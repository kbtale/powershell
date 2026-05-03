#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Server Agent job step information

.DESCRIPTION
    Retrieves details for one or more steps within SQL Server Agent jobs. This script allows filtering by job name and step name, providing structured data about commands, last run status, and execution logic.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER JobName
    Specifies the name of the target Job object

.PARAMETER StepName
    Specifies the name of the JobStep object to retrieve

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Name,Command. Use * for all properties

.EXAMPLE
    PS> ./Get-AgentJobStep.ps1 -ServerInstance "localhost\SQLEXPRESS" -JobName "BackupJob"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(  
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$JobName,
    [string]$StepName,
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','Name','ID','State','Command','LastRunDate','LastRunDuration','LastRunDurationAsTimeSpan','OnFailAction','OnSuccessAction')]
    [string[]]$Properties = @('Name','ID','State','Command','LastRunDate','LastRunDuration','LastRunDurationAsTimeSpan','OnFailAction','OnSuccessAction')
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

    [hashtable]$cmdJob = @{'ErrorAction' = 'Stop'}      
    [hashtable]$cmdStep = @{'ErrorAction' = 'Stop'}      
    
    if (-not [string]::IsNullOrWhiteSpace($JobName)) {
        $cmdJob.Add('Name', $JobName)
    }
    if (-not [string]::IsNullOrWhiteSpace($StepName)) {
        $cmdStep.Add('Name', $StepName)
    }
    
    $agent = Get-SqlAgent -InputObject $instance -ErrorAction Stop
    $jobs = $agent | Get-SqlAgentJob @cmdJob
    $result = $jobs | Get-SqlAgentJobStep @cmdStep | Select-Object $Properties
    
    Write-Output $result
} catch {
    throw
}
