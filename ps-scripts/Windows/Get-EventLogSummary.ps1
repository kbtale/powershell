#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves a summary of recent errors and warnings from event logs

.DESCRIPTION
    Queries specified Windows Event Logs for recent high-severity entries (Errors and Warnings). This script provides a quick operational snapshot of system health by aggregating the most critical events from the last 24 hours (or a custom duration).

.PARAMETER LogName
    Specifies the name of the log to query (e.g., "System", "Application").

.PARAMETER MaxEvents
    Specifies the maximum number of events to retrieve per log.

.PARAMETER Hours
    Specifies the time window to look back for events. Defaults to 24 hours.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-EventLogSummary.ps1 -LogName "System" -Hours 12

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [ValidateSet('System', 'Application', 'Security')]
    [string]$LogName,

    [int]$MaxEvents = 50,

    [int]$Hours = 24,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $startTime = (Get-Date).AddHours(-$Hours)
        
        $query = "*[System[(Level=1 or Level=2 or Level=3) and TimeCreated[@SystemTime >= '$($startTime.ToUniversalTime().ToString("s"))Z']]]"

        $eventParams = @{
            'LogName'     = $LogName
            'FilterXPath' = $query
            'MaxEvents'   = $MaxEvents
            'ErrorAction' = 'Stop'
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $eventParams.Add('ComputerName', $ComputerName)
            if ($null -ne $Credential)
            {
                $eventParams.Add('Credential', $Credential)
            }
        }

        $events = Get-WinEvent @eventParams -ErrorAction SilentlyContinue

        if ($null -ne $events)
        {
            $results = foreach ($e in $events)
            {
                [PSCustomObject]@{
                    TimeCreated  = $e.TimeCreated
                    Id           = $e.Id
                    Level        = $e.LevelDisplayName
                    Source       = $e.ProviderName
                    Message      = $e.Message.Trim()
                    ComputerName = $ComputerName
                }
            }

            Write-Output $results
        }
        else
        {
            Write-Verbose "No critical events found in '$LogName' for the last $Hours hours."
        }
    }
    catch
    {
        throw
    }
}
