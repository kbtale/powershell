#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Configures BitLocker automatic unlocking for a volume

.DESCRIPTION
    Enables or disables automatic unlocking for a BitLocker-encrypted data volume on a specified system.

.PARAMETER MountPoint
    Specifies the drive letter or mount point (e.g., "D:").

.PARAMETER Enabled
    If set to true, enables auto-unlock. If false, disables it.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-BitLockerAutoUnlock.ps1 -MountPoint "D:" -Enabled $true

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$MountPoint,

    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Drive, $Enable)
            if ($Enable) {
                Enable-BitLockerAutoUnlock -MountPoint $Drive -ErrorAction Stop
            }
            else {
                Disable-BitLockerAutoUnlock -MountPoint $Drive -ErrorAction Stop
            }
            Get-BitLockerVolume -MountPoint $Drive | Select-Object MountPoint, AutoUnlockEnabled
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($MountPoint, $Enabled)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Drive $MountPoint -Enable $Enabled
        }

        $output = [PSCustomObject]@{
            MountPoint       = $result.MountPoint
            AutoUnlockEnabled = $result.AutoUnlockEnabled
            ComputerName     = $ComputerName
            Action           = if ($Enabled) { "AutoUnlockEnabled" } else { "AutoUnlockDisabled" }
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
