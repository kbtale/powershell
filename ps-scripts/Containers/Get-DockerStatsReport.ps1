#Requires -Version 5.1

<#
.SYNOPSIS
    Containers: Queries and summarizes resource stats of running Docker containers
.DESCRIPTION
    Interrogates the local Docker socket to fetch real-time CPU, memory, and network utilization of all running containers, and returns a sorted report.
.PARAMETER SortBy
    Resource metric to sort the report by. Options are: 'CPU', 'Memory', 'Name'. Defaults to 'CPU'.
.EXAMPLE
    PS> ./Get-DockerStatsReport.ps1 -SortBy Memory
.CATEGORY Containers
#>

[CmdletBinding()]
Param(
    [ValidateSet('CPU', 'Memory', 'Name')]
    [string]$SortBy = 'CPU'
)

Process {
    try {
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
            Write-Warning "Docker CLI is not installed or not found in the system's PATH. Please install Docker and try again."
            return
        }

        $rawStats = docker stats --no-stream --format "{{.ID}},{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}}" 2>$null

        if ($null -eq $rawStats -or $rawStats.Count -eq 0 -or $rawStats -eq "") {
            Write-Host "No active or running Docker containers found." -ForegroundColor Yellow
            return
        }

        $results = @()
        foreach ($line in $rawStats) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            $parts = $line.Split(',')
            if ($parts.Count -lt 6) { continue }

            $id       = $parts[0].Trim()
            $name     = $parts[1].Trim()
            $cpu      = $parts[2].Trim()
            $memUsage = $parts[3].Trim()
            $memPerc  = $parts[4].Trim()
            $netIo    = $parts[5].Trim()

            $cpuNum = 0.0
            $memNum = 0.0
            [double]::TryParse(($cpu -replace '%', '').Trim(), [ref]$cpuNum) | Out-Null
            [double]::TryParse(($memPerc -replace '%', '').Trim(), [ref]$memNum) | Out-Null

            $results += [PSCustomObject]@{
                ContainerID    = $id
                Name           = $name
                CPU            = $cpu
                MemoryUsage    = $memUsage
                MemoryPercent  = $memPerc
                NetworkIO      = $netIo
                CpuNumeric     = $cpuNum
                MemoryNumeric  = $memNum
            }
        }

        switch ($SortBy) {
            'CPU'    { $sorted = $results | Sort-Object CpuNumeric -Descending }
            'Memory' { $sorted = $results | Sort-Object MemoryNumeric -Descending }
            'Name'   { $sorted = $results | Sort-Object Name }
        }

        $cleanResults = foreach ($r in $sorted) {
            $r.PSObject.Properties.Remove('CpuNumeric')
            $r.PSObject.Properties.Remove('MemoryNumeric')
            $r
        }

        Write-Output $cleanResults
    }
    catch {
        Write-Error $_
        throw
    }
}
