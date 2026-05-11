#Requires -Version 5.1

<#
.SYNOPSIS
    Reporting: Retrieves the boot time and uptime report for multiple systems
.DESCRIPTION
    Queries the last boot time using CIM and computes uptime (Days, Hours, Minutes). Highlights machines exceeding a specified reboot threshold.
.PARAMETER ComputerName
    One or more computers or IP addresses to query
.PARAMETER HighlightDays
    The threshold in days after which a machine is flagged as needing a reboot (defaults to 90 days)
.EXAMPLE
    PS> ./Get-SystemUptimeReport.ps1 -ComputerName "localhost", "server02" -HighlightDays 30
.CATEGORY Reporting
#>

[CmdletBinding()]
Param(
    [string[]]$ComputerName = @('localhost'),

    [int]$HighlightDays = 90
)

Process {
    try {
        $results = @()
        foreach ($computer in $ComputerName) {
            try {
                $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
                $lastBoot = $os.LastBootUpTime
                
                if ($null -eq $lastBoot) {
                    Write-Warning "Failed to retrieve LastBootUpTime for computer '$computer'."
                    continue
                }

                  $uptimeSpan = (Get-Date) - $lastBoot
                  
                  $days = $uptimeSpan.Days
                  $hours = $uptimeSpan.Hours
                  $minutes = $uptimeSpan.Minutes
                  
                  $uptimeFormatted = "{0}d {1}h {2}m" -f $days, $hours, $minutes
                  $needsReboot = ($days -ge $HighlightDays)

                  $results += [PSCustomObject]@{
                      ComputerName    = $computer.ToUpper()
                      OSName          = $os.Caption
                      LastBootUpTime  = $lastBoot
                      UptimeDays      = $days
                      UptimeFormatted = $uptimeFormatted
                      NeedsReboot     = $needsReboot
                      Status          = if ($needsReboot) { "Pending Reboot (Online > $HighlightDays days)" } else { "Healthy" }
                  }
            }
            catch {
                Write-Warning "Failed to query system uptime on computer '$computer': $_"
            }
        }

        if ($results.Count -eq 0) {
            Write-Verbose "No uptime data retrieved."
            return
        }

        Write-Output ($results | Sort-Object UptimeDays -Descending)
    }
    catch {
        Write-Error $_
        throw
    }
}
