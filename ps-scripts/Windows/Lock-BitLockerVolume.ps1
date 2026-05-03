#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Locks an unlocked BitLocker volume

.DESCRIPTION
    Re-locks a previously unlocked BitLocker volume, preventing access to the data.

.PARAMETER MountPoint
    Specifies the drive letter or mount point (e.g., "D:").

.PARAMETER ForceDismount
    If set, forces the volume to lock even if it is currently in use.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Lock-BitLockerVolume.ps1 -MountPoint "D:" -ForceDismount

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$MountPoint,

    [switch]$ForceDismount,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Drive, $Force)
            Lock-BitLocker -MountPoint $Drive -ForceDismount:$Force -Confirm:$false -ErrorAction Stop
            Get-BitLockerVolume -MountPoint $Drive | Select-Object MountPoint, VolumeStatus, ProtectionStatus
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($MountPoint, $ForceDismount)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Drive $MountPoint -Force $ForceDismount
        }

        $output = [PSCustomObject]@{
            MountPoint       = $result.MountPoint
            VolumeStatus     = $result.VolumeStatus
            ProtectionStatus = $result.ProtectionStatus
            ComputerName     = $ComputerName
            Action           = "VolumeLocked"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
