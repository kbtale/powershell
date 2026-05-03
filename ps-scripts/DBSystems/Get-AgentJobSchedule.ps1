#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Server Agent job schedule information

.DESCRIPTION
    Retrieves schedule details for one or more SQL Server Agent jobs. This script allows filtering by job name and schedule name, providing structured data about active dates, frequency, and status.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER JobName
    Specifies the name of the target Job object

.PARAMETER ScheduleName
    Specifies the name of the JobSchedule object to retrieve

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Name,IsEnabled. Use * for all properties

.EXAMPLE
    PS> ./Get-AgentJobSchedule.ps1 -ServerInstance "localhost\SQLEXPRESS" -JobName "BackupJob"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(  
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$JobName,
    [string]$ScheduleName,
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','Name','ID','State','ActiveStartDate','ActiveEndDate','DateCreated','FrequencyTypes','IsEnabled','JobCount')]
    [string[]]$Properties = @('Name','ID','State','ActiveStartDate','ActiveEndDate','DateCreated','FrequencyTypes','IsEnabled','JobCount')
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
    [hashtable]$cmdSchedule = @{'ErrorAction' = 'Stop'}      
    
    if (-not [string]::IsNullOrWhiteSpace($JobName)) {
        $cmdJob.Add('Name', $JobName)
    }
    if (-not [string]::IsNullOrWhiteSpace($ScheduleName)) {
        $cmdSchedule.Add('Name', $ScheduleName)
    }
    
    $agent = Get-SqlAgent -InputObject $instance -ErrorAction Stop
    $jobs = $agent | Get-SqlAgentJob @cmdJob
    $result = $jobs | Get-SqlAgentJobSchedule @cmdSchedule | Select-Object $Properties
    
    Write-Output $result
} catch {
    throw
}
