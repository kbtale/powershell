#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Retrieves Windows Defender scan and update preferences

.DESCRIPTION
    Gets the configuration settings and exclusions for Windows Defender Antivirus on a local or remote computer.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-DefenderPreferenceInfo.ps1 -ComputerName "SRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        if ($ComputerName -ne $env:COMPUTERNAME) {
            $sessionParams = @{
                'ComputerName' = $ComputerName
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            $prefs = Get-MpPreference -CimSession $session -ErrorAction Stop
        }
        else {
            $prefs = Get-MpPreference -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            ExclusionPath        = $prefs.ExclusionPath
            ExclusionExtension   = $prefs.ExclusionExtension
            ExclusionProcess     = $prefs.ExclusionProcess
            RealTimeScanDirection = $prefs.RealTimeScanDirection
            ScanScheduleDay      = $prefs.ScanScheduleDay
            ScanScheduleTime     = $prefs.ScanScheduleTime
            MAPSReporting        = $prefs.MAPSReporting
            ComputerName         = $ComputerName
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
