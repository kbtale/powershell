#Requires -Version 5.1
#Requires -Modules ScheduledTasks

<#
.SYNOPSIS
    Windows: Starts an existing scheduled task immediately

.DESCRIPTION
    Triggers the manual execution of a registered scheduled task on a local or remote computer. This script provides immediate feedback on the task's state transition after the start command is issued.

.PARAMETER Name
    Specifies the name of the scheduled task to start.

.PARAMETER TaskPath
    Specifies the path of the task in the Task Scheduler hierarchy. Defaults to the root (\).

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Start-ScheduledTaskRemote.ps1 -Name "DailyBackup" -ComputerName "SRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$Name,

    [string]$TaskPath = "\",

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $taskParams = @{
            'TaskName'    = $Name
            'TaskPath'    = $TaskPath
            'ErrorAction' = 'Stop'
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $sessionParams = @{
                'ComputerName' = $ComputerName
            }
            if ($null -ne $Credential) {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            $taskParams.Add('CimSession', $session)
        }

        Write-Verbose "Attempting to start scheduled task '$Name' on '$ComputerName'..."
        $task = Get-ScheduledTask @taskParams
        Start-ScheduledTask -InputObject $task @taskParams | Out-Null

        $updatedTask = Get-ScheduledTask @taskParams
        $result = [PSCustomObject]@{
            TaskName     = $updatedTask.TaskName
            State        = $updatedTask.State
            ComputerName = $ComputerName
            Action       = "Started"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
    finally {
        if ($null -ne $session) {
            Remove-CimSession $session
        }
    }
}
