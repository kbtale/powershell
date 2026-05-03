#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Enables BitLocker encryption on a specified volume

.DESCRIPTION
    Activates BitLocker encryption for a local or remote volume. This script supports various protectors including TPM and Recovery Password. It also allows configuring the encryption method and hardware encryption settings.

.PARAMETER MountPoint
    Specifies the drive letter or mount point of the volume to encrypt (e.g., "C:").

.PARAMETER EncryptionMethod
    Specifies the encryption algorithm. Valid values: Aes128, Aes256, XtsAes128, XtsAes256.

.PARAMETER TpmProtector
    If set, uses the TPM as a key protector.

.PARAMETER UsedSpaceOnly
    If set, only encrypts used disk space instead of the entire drive.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Enable-BitLockerRemote.ps1 -MountPoint "D:" -TpmProtector

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$MountPoint,

    [ValidateSet('Aes128', 'Aes256', 'XtsAes128', 'XtsAes256')]
    [string]$EncryptionMethod = 'XtsAes256',

    [switch]$TpmProtector,

    [switch]$UsedSpaceOnly,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Drive, $Method, $UseTpm, $SpaceOnly)
            $params = @{
                'MountPoint'       = $Drive
                'EncryptionMethod' = $Method
                'UsedSpaceOnly'    = $SpaceOnly
                'Confirm'          = $false
                'ErrorAction'      = 'Stop'
            }
            if ($UseTpm) { $params.Add('TpmProtector', $true) }
            
            Enable-BitLocker @params
            Get-BitLockerVolume -MountPoint $Drive | Select-Object MountPoint, EncryptionMethod, VolumeStatus, ProtectionStatus
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($MountPoint, $EncryptionMethod, $TpmProtector, $UsedSpaceOnly)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Drive $MountPoint -Method $EncryptionMethod -UseTpm $TpmProtector -SpaceOnly $UsedSpaceOnly
        }

        $output = [PSCustomObject]@{
            MountPoint       = $result.MountPoint
            EncryptionMethod = $result.EncryptionMethod
            VolumeStatus     = $result.VolumeStatus
            ProtectionStatus = $result.ProtectionStatus
            ComputerName     = $ComputerName
            Action           = "EncryptionEnabled"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
