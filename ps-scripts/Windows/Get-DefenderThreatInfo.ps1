#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Retrieves information about threats detected by Windows Defender

.DESCRIPTION
    Gets the history of threats detected on a local or remote computer, including threat names, IDs, and severity levels.

.PARAMETER ThreatID
    Specifies the ID of a specific threat to retrieve.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-DefenderThreatInfo.ps1 -ComputerName "WS01"

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
        $threatParams = @{
            'ErrorAction' = 'Stop'
        }
        if ($ThreatID -gt 0) {
            $threatParams.Add('ThreatID', $ThreatID)
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
            $threatParams.Add('CimSession', $session)
        }

        $threats = Get-MpThreat @threatParams

        $results = foreach ($t in $threats) {
            [PSCustomObject]@{
                ThreatName   = $t.ThreatName
                ThreatID     = $t.ThreatID
                SeverityID   = $t.SeverityID
                CategoryID   = $t.CategoryID
                TypeID       = $t.TypeID
                ComputerName = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object ThreatName)
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
