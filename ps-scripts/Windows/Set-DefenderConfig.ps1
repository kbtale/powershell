#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Configures Windows Defender Antivirus settings

.DESCRIPTION
    Updates preferences for Windows Defender Antivirus on a local or remote computer. Supports configuring real-time protection, behavior monitoring, and scan schedules.

.PARAMETER DisableRealtimeMonitoring
    Enables or disables real-time protection.

.PARAMETER DisableBehaviorMonitoring
    Enables or disables behavior monitoring.

.PARAMETER DisableIOAVProtection
    Enables or disables scanning of all downloaded files and attachments.

.PARAMETER ScanAvgCPULoadFactor
    Specifies the maximum percentage CPU usage for a scan (1-100).

.PARAMETER ScanScheduleDay
    Specifies the day of the week to perform a scheduled scan.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-DefenderConfig.ps1 -DisableRealtimeMonitoring $false -ScanAvgCPULoadFactor 30

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [bool]$DisableRealtimeMonitoring,

    [bool]$DisableBehaviorMonitoring,

    [bool]$DisableIOAVProtection,

    [ValidateRange(1, 100)]
    [int]$ScanAvgCPULoadFactor,

    [ValidateSet('Everyday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Never')]
    [string]$ScanScheduleDay,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $prefParams = @{
            'Force'       = $true
            'ErrorAction' = 'Stop'
        }

        foreach ($key in $PSBoundParameters.Keys) {
            if ($key -notin @('ComputerName', 'Credential')) {
                $prefParams.Add($key, $PSBoundParameters[$key])
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $sessionParams = @{
                'ComputerName' = $ComputerName
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            $prefParams.Add('CimSession', $session)
        }

        if ($prefParams.Count -gt 2) {
            Set-MpPreference @prefParams
        }

        $status = if ($session) { Get-MpPreference -CimSession $session } else { Get-MpPreference }

        $result = [PSCustomObject]@{
            DisableRealtimeMonitoring = $status.DisableRealtimeMonitoring
            DisableBehaviorMonitoring = $status.DisableBehaviorMonitoring
            ScanAvgCPULoadFactor      = $status.ScanAvgCPULoadFactor
            ScanScheduleDay           = $status.ScanScheduleDay
            ComputerName              = $ComputerName
            Action                    = "DefenderConfigUpdated"
            Status                    = "Success"
            Timestamp                 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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
