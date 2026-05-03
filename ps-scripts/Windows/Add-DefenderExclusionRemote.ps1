#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Adds exclusions to Windows Defender Antivirus

.DESCRIPTION
    Adds file paths, extensions, or processes to the exclusion list for Windows Defender scans on a local or remote computer.

.PARAMETER ExclusionPath
    Specifies an array of file or folder paths to exclude from scanning.

.PARAMETER ExclusionExtension
    Specifies an array of file extensions to exclude from scanning (e.g., ".txt", ".log").

.PARAMETER ExclusionProcess
    Specifies an array of process names (e.g., "app.exe") to exclude from scanning.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Add-DefenderExclusionRemote.ps1 -ExclusionPath "C:\Data"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string[]]$ExclusionPath,

    [string[]]$ExclusionExtension,

    [string[]]$ExclusionProcess,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $prefParams = @{
            'ErrorAction' = 'Stop'
        }
        if ($ExclusionPath) { $prefParams.Add('ExclusionPath', $ExclusionPath) }
        if ($ExclusionExtension) { $prefParams.Add('ExclusionExtension', $ExclusionExtension) }
        if ($ExclusionProcess) { $prefParams.Add('ExclusionProcess', $ExclusionProcess) }

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

        if ($prefParams.Count -gt 1) {
            Add-MpPreference @prefParams
        }

        $prefs = if ($session) { Get-MpPreference -CimSession $session } else { Get-MpPreference }

        $result = [PSCustomObject]@{
            ExclusionPath      = $prefs.ExclusionPath
            ExclusionExtension = $prefs.ExclusionExtension
            ExclusionProcess   = $prefs.ExclusionProcess
            ComputerName       = $ComputerName
            Action             = "ExclusionsAdded"
            Status             = "Success"
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
