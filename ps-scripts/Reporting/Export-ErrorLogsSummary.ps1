#Requires -Version 5.1

<#
.SYNOPSIS
    Reporting: Summarizes Windows Event Log errors from the past N hours
.DESCRIPTION
    Queries Windows Event Logs (System and Application) for Critical and Error events from the last N hours, returning details or a grouped count summary.
.PARAMETER ComputerName
    One or more computers or IP addresses to query
.PARAMETER Hours
    Lookback duration in hours. Defaults to 24.
.PARAMETER LogName
    Target event logs to query. Defaults to System and Application.
.PARAMETER Summarize
    Group and count duplicate events by Source and EventID rather than returning individual events
.EXAMPLE
    PS> ./Export-ErrorLogsSummary.ps1 -Hours 12 -Summarize
.CATEGORY Reporting
#>

[CmdletBinding()]
Param(
    [string[]]$ComputerName = @('localhost'),

    [int]$Hours = 24,

    [string[]]$LogName = @('System', 'Application'),

    [switch]$Summarize
)

Process {
    try {
        if ($Hours -le 0) {
            throw "Hours parameter must be a positive integer."
        }

        $startTime = (Get-Date).AddHours(-$Hours)
        $results = @()

        foreach ($computer in $ComputerName) {
            try {
                $filterHash = @{
                    LogName   = $LogName
                    Level     = @(1, 2) # 1 = Critical, 2 = Error
                    StartTime = $startTime
                }

                $events = Get-WinEvent -FilterHashtable $filterHash -ComputerName $computer -ErrorAction SilentlyContinue

                if ($null -eq $events) {
                    continue
                }

                foreach ($event in $events) {
                    $results += [PSCustomObject]@{
                        ComputerName     = $computer.ToUpper()
                        LogName          = $event.LogName
                        ProviderName     = $event.ProviderName
                        EventID          = $event.Id
                        LevelDisplayName = $event.LevelDisplayName
                        TimeCreated      = $event.TimeCreated
                        Message          = $event.Message.Trim()
                    }
                }
            }
            catch {
                Write-Warning "Failed to query event logs on computer '$computer': $_"
            }
        }

        if ($results.Count -eq 0) {
            Write-Verbose "No Critical or Error event logs found within the last $Hours hours."
            return
        }

        if ($Summarize) {
            # Group by Computer, Log, Source, and ID
            $grouped = $results | Group-Object ComputerName, LogName, ProviderName, EventID
            $summary = foreach ($g in $grouped) {
                # Extract the properties from group values
                $firstEvent = $g.Group[0]
                [PSCustomObject]@{
                    ComputerName = $firstEvent.ComputerName
                    LogName      = $firstEvent.LogName
                    Source       = $firstEvent.ProviderName
                    EventID      = $firstEvent.EventID
                    Severity     = $firstEvent.LevelDisplayName
                    Count        = $g.Count
                    SampleMessage= if ($firstEvent.Message.Length -gt 150) { $firstEvent.Message.Substring(0, 150) + "..." } else { $firstEvent.Message }
                }
            }
            Write-Output ($summary | Sort-Object Count -Descending)
        } else {
            Write-Output ($results | Sort-Object TimeCreated -Descending)
        }
    }
    catch {
        Write-Error $_
        throw
    }
}
