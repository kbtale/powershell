#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Initiates a Windows Defender Antivirus scan

.DESCRIPTION
    Starts a Full, Quick, or Custom antimalware scan on a local or remote computer. Custom scans require a specific path.

.PARAMETER ScanType
    Specifies the type of scan to perform. Valid values: FullScan, QuickScan, CustomScan.

.PARAMETER ScanPath
    Specifies the path to scan for a CustomScan.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Start-DefenderScanRemote.ps1 -ScanType QuickScan

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [ValidateSet('FullScan', 'QuickScan', 'CustomScan')]
    [string]$ScanType = "QuickScan",

    [string]$ScanPath,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $scanParams = @{
            'ScanType'    = $ScanType
            'ErrorAction' = 'Stop'
        }
        if ($ScanType -eq 'CustomScan' -and [string]::IsNullOrWhiteSpace($ScanPath)) {
            throw "ScanPath must be specified for CustomScan"
        }
        if ($ScanPath) {
            $scanParams.Add('ScanPath', $ScanPath)
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
            $scanParams.Add('CimSession', $session)
        }

        # Run scan as job if remote to avoid timeout
        if ($session) {
            $scanParams.Add('AsJob', $true)
            $job = Start-MpScan @scanParams
            $result = [PSCustomObject]@{
                JobId        = $job.Id
                ScanType     = $ScanType
                Status       = "InitiatedAsJob"
                ComputerName = $ComputerName
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
        else {
            Start-MpScan @scanParams
            $result = [PSCustomObject]@{
                ScanType     = $ScanType
                Status       = "Completed"
                ComputerName = $ComputerName
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
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
