#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Renames a local or remote computer

.DESCRIPTION
    Updates the computer name in the system configuration. This operation requires a reboot to take effect.

.PARAMETER NewName
    Specifies the new name for the computer.

.PARAMETER ComputerName
    Specifies the name of the target computer to rename. Defaults to the local computer.

.PARAMETER Reboot
    If set, reboots the computer after the name change.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-ComputerNameRemote.ps1 -NewName "SRV-APPS-01" -Reboot

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$NewName,

    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$Reboot,

    [pscredential]$Credential
)

Process {
    try {
        $renameParams = @{
            'NewName'     = $NewName
            'ErrorAction' = 'Stop'
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $renameParams.Add('ComputerName', $ComputerName)
            if ($null -ne $Credential) {
                $renameParams.Add('Credential', $Credential)
            }
        }

        Write-Verbose "Renaming computer to '$NewName'..."
        Rename-Computer @renameParams

        if ($Reboot) {
            Write-Verbose "Initiating reboot..."
            $restartParams = @{
                'Force'       = $true
                'Confirm'     = $false
                'ErrorAction' = 'Stop'
            }
            if ($ComputerName -ne $env:COMPUTERNAME) {
                $restartParams.Add('ComputerName', $ComputerName)
                if ($null -ne $Credential) {
                    $restartParams.Add('Credential', $Credential)
                }
            }
            Restart-Computer @restartParams
        }

        $result = [PSCustomObject]@{
            OldName      = $ComputerName
            NewName      = $NewName
            Reboot       = if ($Reboot) { "Initiated" } else { "Required" }
            ComputerName = $ComputerName
            Status       = "Renamed"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
