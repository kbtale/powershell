#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Retrieves the current status of Windows Defender Antivirus

.DESCRIPTION
    Gets the antimalware software status on a local or remote computer, including engine version, signature version, and real-time protection status.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-DefenderStatusInfo.ps1 -ComputerName "SRV01"

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
            $status = Get-MpComputerStatus -CimSession $session -ErrorAction Stop
        }
        else {
            $status = Get-MpComputerStatus -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            AMEngineVersion      = $status.AMEngineVersion
            AMServiceVersion     = $status.AMServiceVersion
            AntispywareEnabled   = $status.AntispywareEnabled
            AntivirusEnabled     = $status.AntivirusEnabled
            RealTimeProtectionEnabled = $status.RealTimeProtectionEnabled
            AntivirusSignatureVersion = $status.AntivirusSignatureVersion
            LastFullScanTime     = $status.FullScanAge
            ComputerName         = $ComputerName
            Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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
