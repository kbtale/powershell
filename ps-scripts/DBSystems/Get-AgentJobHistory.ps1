#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Server Agent job execution history

.DESCRIPTION
    Retrieves execution history for SQL Server Agent jobs. Supports advanced filtering by job name, date range, duration, and outcome status. This script is ideal for auditing job performance and troubleshooting failures.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER JobName
    Specifies a job filter constraint that restricts the values returned to the job specified by the name of the job

.PARAMETER JobID
    Specifies a job filter constraint that restricts the values returned to the job specified by the job ID value

.PARAMETER StartRunDate
    Specifies a job filter constraint that restricts the values returned to the date the job started

.PARAMETER EndRunDate
    Specifies a job filter constraint that restricts the values returned to the date the job completed

.PARAMETER MinimumRunDurationInSeconds
    Specifies a job filter constraint that restricts the values returned to jobs that have completed in the minimum length of time specified, in seconds

.PARAMETER Since
    Specifies an abbreviation for the StartRunDate parameter

.PARAMETER OldestFirst
    Indicates that this cmdlet lists jobs in oldest-first order. If you do not specify this parameter, the cmdlet uses newest-first order

.PARAMETER OutcomesType
    Specifies a job filter constraint that restricts the values returned to jobs that have the specified outcome at completion

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Get-AgentJobHistory.ps1 -ServerInstance "localhost\SQLEXPRESS" -Since Yesterday -OutcomesType Failed

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(  
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$JobName,
    [guid]$JobID,
    [datetime]$StartRunDate,
    [datetime]$EndRunDate,
    [int]$MinimumRunDurationInSeconds,
    [switch]$OldestFirst,
    [ValidateSet('Failed', 'Succeeded', 'Retry', 'Cancelled', 'InProgress', 'Unknown')]
    [string]$OutcomesType,
    [ValidateSet('Midnight', 'Yesterday', 'LastWeek', 'LastMonth')]
    [string]$Since,
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

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'OldestFirst' = $OldestFirst.ToBool()
    }      
    if (-not [string]::IsNullOrWhiteSpace($JobName)) {
        $cmdArgs.Add('JobName', $JobName)
    }
    if ($null -ne $JobID -and $JobID -ne [guid]::Empty) {
        $cmdArgs.Add('JobID', $JobID)
    }
    if ($MinimumRunDurationInSeconds -gt 0) {
        $cmdArgs.Add('MinimumRunDurationInSeconds', $MinimumRunDurationInSeconds)
    }
    if ($null -eq $StartRunDate -and -not [string]::IsNullOrWhiteSpace($Since)) {
        $cmdArgs.Add('Since', $Since)
    }
    if ($null -ne $EndRunDate) {
        $cmdArgs.Add('EndRunDate', $EndRunDate)
    }
    if ($null -ne $StartRunDate) {
        $cmdArgs.Add('StartRunDate', $StartRunDate)
    }
    if (-not [string]::IsNullOrWhiteSpace($OutcomesType)) {
        $cmdArgs.Add('OutcomesType', $OutcomesType)
    }

    $agent = Get-SqlAgent -InputObject $instance -ErrorAction Stop
    $result = $agent | Get-SqlAgentJobHistory @cmdArgs | Select-Object *
    
    Write-Output $result
} catch {
    throw
}
