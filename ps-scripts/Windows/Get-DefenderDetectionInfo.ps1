#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Retrieves history of malware detections by Windows Defender

.DESCRIPTION
    Gets details of active and past malware detections on a local or remote computer, including detection time, action taken, and cleaning status.

.PARAMETER ThreatID
    Specifies the ID of a specific threat detection to retrieve.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-DefenderDetectionInfo.ps1 -ComputerName "SRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [int64]$ThreatID,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $detectParams = @{
            'ErrorAction' = 'Stop'
        }
        if ($ThreatID -gt 0) {
            $detectParams.Add('ThreatID', $ThreatID)
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
            $detectParams.Add('CimSession', $session)
        }

        $detections = Get-MpThreatDetection @detectParams

        $results = foreach ($d in $detections) {
            [PSCustomObject]@{
                ThreatName         = $d.ThreatName
                DetectionID        = $d.DetectionID
                InitialDetectionTime = $d.InitialDetectionTime
                LastModificationTime = $d.LastModificationTime
                ActionSuccess      = $d.ActionSuccess
                CleaningActionID   = $d.CleaningActionID
                ComputerName       = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object InitialDetectionTime -Descending)
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
