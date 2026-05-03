#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Disables BitLocker encryption and decrypts the volume

.DESCRIPTION
    Triggers the decryption process and disables BitLocker protection for a local or remote volume.

.PARAMETER MountPoint
    Specifies the drive letter or mount point of the volume to decrypt (e.g., "C:").

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Disable-BitLockerRemote.ps1 -MountPoint "D:"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$MountPoint,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Drive)
            Disable-BitLocker -MountPoint $Drive -Confirm:$false -ErrorAction Stop
            Get-BitLockerVolume -MountPoint $Drive | Select-Object MountPoint, VolumeStatus, ProtectionStatus
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $MountPoint
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Drive $MountPoint
        }

        $output = [PSCustomObject]@{
            MountPoint       = $result.MountPoint
            VolumeStatus     = $result.VolumeStatus
            ProtectionStatus = $result.ProtectionStatus
            ComputerName     = $ComputerName
            Action           = "DecryptionInitiated"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
