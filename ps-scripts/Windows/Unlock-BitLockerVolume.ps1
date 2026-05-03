#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Unlocks a BitLocker-encrypted volume

.DESCRIPTION
    Restores access to a BitLocker volume using a password, recovery password, or recovery key file.

.PARAMETER MountPoint
    Specifies the drive letter or mount point (e.g., "D:").

.PARAMETER Password
    Specifies a secure string used as the volume password.

.PARAMETER RecoveryPassword
    Specifies the 48-digit recovery password as a string.

.PARAMETER RecoveryKeyPath
    Specifies the path to a recovery key file (.bek).

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Unlock-BitLockerVolume.ps1 -MountPoint "D:" -RecoveryPassword "123456-..."

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$MountPoint,

    [Parameter(ParameterSetName = 'Password')]
    [securestring]$Password,

    [Parameter(ParameterSetName = 'RecoveryPassword')]
    [securestring]$RecoveryPassword,

    [Parameter(ParameterSetName = 'RecoveryKey')]
    [string]$RecoveryKeyPath,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Drive, $Pass, $RecPass, $KeyPath, $SetName)
            $params = @{
                'MountPoint'  = $Drive
                'Confirm'      = $false
                'ErrorAction'  = 'Stop'
            }
            if ($SetName -eq 'Password') {
                $params.Add('Password', $Pass)
            }
            elseif ($SetName -eq 'RecoveryPassword') {
                $plainRecPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($RecPass))
                $params.Add('RecoveryPassword', $plainRecPass)
            }
            elseif ($SetName -eq 'RecoveryKey') {
                $params.Add('RecoveryKeyPath', $KeyPath)
            }

            Unlock-BitLocker @params
            Get-BitLockerVolume -MountPoint $Drive | Select-Object MountPoint, VolumeStatus, ProtectionStatus
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($MountPoint, $Password, $RecoveryPassword, $RecoveryKeyPath, $PSCmdlet.ParameterSetName)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Drive $MountPoint -Pass $Password -RecPass $RecoveryPassword -KeyPath $RecoveryKeyPath -SetName $PSCmdlet.ParameterSetName
        }

        $output = [PSCustomObject]@{
            MountPoint       = $result.MountPoint
            VolumeStatus     = $result.VolumeStatus
            ProtectionStatus = $result.ProtectionStatus
            ComputerName     = $ComputerName
            Action           = "VolumeUnlocked"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
