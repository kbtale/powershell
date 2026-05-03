#Requires -Version 5.1
#Requires -Modules ScheduledTasks

<#
.SYNOPSIS
    Windows: Retrieves detailed information about scheduled tasks

.DESCRIPTION
    Lists registered scheduled tasks on a local or remote computer. This script provides an operational overview including task state, last run time, next run time, and configured actions (executables/scripts).

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER TaskName
    Specifies the name of the task to retrieve. Supports wildcards.

.PARAMETER TaskPath
    Specifies the path in the Task Scheduler hierarchy (e.g., "\Microsoft\Windows\").

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-ScheduledTaskInfo.ps1 -TaskName "Backup*"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$TaskName = "*",

    [string]$TaskPath = "\",

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $taskParams = @{
            'TaskName'    = $TaskName
            'TaskPath'    = $TaskPath
            'ErrorAction' = 'Stop'
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $sessionParams = @{
                'ComputerName' = $ComputerName
            }
            if ($null -ne $Credential)
            {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            $taskParams.Add('CimSession', $session)
        }

        $tasks = Get-ScheduledTask @taskParams

        $results = foreach ($task in $tasks)
        {
            $info = $task | Get-ScheduledTaskInfo @taskParams -ErrorAction SilentlyContinue
            
            [PSCustomObject]@{
                TaskName     = $task.TaskName
                TaskPath     = $task.TaskPath
                State        = $task.State
                LastRunTime  = if ($info) { $info.LastRunTime } else { "N/A" }
                NextRunTime  = if ($info) { $info.NextRunTime } else { "N/A" }
                LastTaskResult = if ($info) { $info.LastTaskResult } else { 0 }
                Author       = $task.Author
                Action       = ($task.Actions.Execute + " " + $task.Actions.Arguments).Trim()
                ComputerName = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object TaskName)
    }
    catch
    {
        throw
    }
    finally
    {
        if ($null -ne $session)
        {
            Remove-CimSession $session
        }
    }
}
