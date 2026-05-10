#Requires -Version 5.1

<#
.SYNOPSIS
    Reporting: Generates an HTML disk space report for local or remote computers
.DESCRIPTION
    Queries local disks (DriveType = 3) on one or more computers, checks their free space against a warning threshold, and generates a beautifully styled HTML report.
.PARAMETER ComputerName
    One or more computer names or IP addresses to query
.PARAMETER ThresholdPercent
    Disk free space percentage threshold. Items with free space below this will be highlighted in Red.
.PARAMETER OutputPath
    Optional file path to save the generated HTML report
.EXAMPLE
    PS> ./Get-DiskSpaceReport.ps1 -ComputerName "localhost", "server01" -ThresholdPercent 15 -OutputPath "C:\Reports\DiskSpace.html"
.CATEGORY Reporting
#>

[CmdletBinding()]
Param(
    [string[]]$ComputerName = @('localhost'),

    [int]$ThresholdPercent = 15,

    [string]$OutputPath = ''
)

Process {
    try {
        $diskData = @()
        foreach ($computer in $ComputerName) {
            try {
                $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3" -ErrorAction Stop
                foreach ($disk in $disks) {
                    $size = $disk.Size
                    $free = $disk.FreeSpace
                    
                    if ($null -eq $size -or $size -eq 0) { continue }
                    
                    $percentFree = [Math]::Round(($free / $size) * 100, 2)
                    $sizeGB = [Math]::Round($size / 1GB, 2)
                    $freeGB = [Math]::Round($free / 1GB, 2)
                    $usedGB = [Math]::Round(($size - $free) / 1GB, 2)

                    $status = if ($percentFree -lt $ThresholdPercent) { 'Critical' } else { 'Healthy' }

                    $diskData += [PSCustomObject]@{
                        Computer    = $computer.ToUpper()
                        Drive       = $disk.DeviceID
                        VolumeName  = $disk.VolumeName
                        SizeGB      = $sizeGB
                        UsedGB      = $usedGB
                        FreeGB      = $freeGB
                        PercentFree = $percentFree
                        Status      = $status
                    }
                }
            }
            catch {
                Write-Warning "Failed to query computer '$computer': $_"
            }
        }

        if ($diskData.Count -eq 0) {
            Write-Output "No disk data retrieved."
            return
        }

        # Build clean styled HTML report
        $html = @'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Disk Space Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 30px; background-color: #f5f7fa; color: #333; }
        h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .timestamp { color: #7f8c8d; font-size: 0.9em; margin-bottom: 20px; }
        table { border-collapse: collapse; width: 100%; box-shadow: 0 4px 6px rgba(0,0,0,0.1); background-color: white; border-radius: 4px; overflow: hidden; }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e1e8ed; }
        th { background-color: #34495e; color: white; font-weight: 600; text-transform: uppercase; font-size: 0.85em; letter-spacing: 0.5px; }
        tr:hover { background-color: #f1f5f9; }
        .critical { background-color: #fadbd8; color: #c0392b; font-weight: bold; }
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; text-transform: uppercase; }
        .badge-healthy { background-color: #2ecc71; color: white; }
        .badge-critical { background-color: #e74c3c; color: white; }
    </style>
</head>
<body>
    <h1>Disk Space Status Report</h1>
'@
        $html += "    <div class='timestamp'>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Warning Threshold: < $ThresholdPercent% Free</div>"
        $html += "    <table>"
        $html += "        <tr>"
        $html += "            <th>Computer</th><th>Drive</th><th>Volume Name</th><th>Size (GB)</th><th>Used (GB)</th><th>Free (GB)</th><th>% Free</th><th>Status</th>"
        $html += "        </tr>"

        foreach ($row in $diskData) {
            $classAttr = if ($row.Status -eq 'Critical') { " class='critical'" } else { "" }
            $badgeAttr = if ($row.Status -eq 'Critical') { "<span class='badge badge-critical'>Critical</span>" } else { "<span class='badge badge-healthy'>Healthy</span>" }
            
            $html += "        <tr$classAttr>"
            $html += "            <td>$($row.Computer)</td>"
            $html += "            <td>$($row.Drive)</td>"
            $html += "            <td>$($row.VolumeName)</td>"
            $html += "            <td>$($row.SizeGB)</td>"
            $html += "            <td>$($row.UsedGB)</td>"
            $html += "            <td>$($row.FreeGB)</td>"
            $html += "            <td>$($row.PercentFree)%</td>"
            $html += "            <td>$badgeAttr</td>"
            $html += "        </tr>"
        }

        $html += @'
    </table>
</body>
</html>
'@

        if ($OutputPath) {
            $parentDir = Split-Path -Path $OutputPath -Parent
            if ($parentDir -and -not (Test-Path -Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            $html | Out-File -FilePath $OutputPath -Encoding utf8 -Force
            Write-Host "Disk space report written to: $OutputPath"
        } else {
            Write-Output $html
        }
    }
    catch {
        Write-Error $_
        throw
    }
}
