#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Adds a key protector to a BitLocker volume

.DESCRIPTION
    Configures additional key protectors for an existing BitLocker volume. Supports Recovery Password, TPM, and User Password.

.PARAMETER MountPoint
    Specifies the drive letter or mount point (e.g., "C:").

.PARAMETER RecoveryPassword
    If set, generates and adds a random recovery password protector.

.PARAMETER TpmProtector
    If set, adds the TPM as a protector.

.PARAMETER Password
    Specifies a secure string to be used as a password protector.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Add-BitLockerKeyProtector.ps1 -MountPoint "C:" -RecoveryPassword

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$MountPoint,

    [switch]$RecoveryPassword,

    [switch]$TpmProtector,

    [securestring]$Password,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Drive, $AddRecovery, $AddTpm, $Pass)
            if ($AddRecovery) {
                Add-BitLockerKeyProtector -MountPoint $Drive -RecoveryPasswordProtector -ErrorAction Stop
            }
            if ($AddTpm) {
                Add-BitLockerKeyProtector -MountPoint $Drive -TpmProtector -ErrorAction Stop
            }
            if ($null -ne $Pass) {
                Add-BitLockerKeyProtector -MountPoint $Drive -PasswordProtector -Password $Pass -ErrorAction Stop
            }
            
            Get-BitLockerVolume -MountPoint $Drive | Select-Object -ExpandProperty KeyProtector
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($MountPoint, $RecoveryPassword, $TpmProtector, $Password)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Drive $MountPoint -AddRecovery $RecoveryPassword -AddTpm $TpmProtector -Pass $Password
        }

        $output = foreach ($p in $result) {
            [PSCustomObject]@{
                MountPoint       = $MountPoint
                KeyProtectorId   = $p.KeyProtectorId
                KeyProtectorType = $p.KeyProtectorType
                RecoveryPassword = $p.RecoveryPassword
                ComputerName     = $ComputerName
            }
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
