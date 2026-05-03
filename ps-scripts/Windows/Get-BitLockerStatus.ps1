#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Retrieves BitLocker encryption status and key protectors

.DESCRIPTION
    Audits the BitLocker encryption state for all volumes on a local or remote computer. This script identifies encryption methods, protection status, and the presence of key protectors (Recovery Password, TPM, etc.).

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER DriveLetter
    Specifies a specific drive (e.g., "C:") to query. If omitted, all volumes are audited.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-BitLockerStatus.ps1 -ComputerName "LAPTOP-X1"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$DriveLetter,

    [pscredential]$Credential
)

Process
{
    try
    {
        $scriptBlock = {
            Param($MountPoint)
            $volumes = if ($null -ne $MountPoint) { Get-BitLockerVolume -MountPoint $MountPoint -ErrorAction Stop } else { Get-BitLockerVolume -ErrorAction Stop }
            
            $results = foreach ($v in $volumes)
            {
                [PSCustomObject]@{
                    MountPoint        = $v.MountPoint
                    ProtectionStatus  = $v.ProtectionStatus
                    EncryptionMethod  = $v.EncryptionMethod
                    VolumeStatus      = $v.VolumeStatus
                    KeyProtectors     = ($v.KeyProtector.KeyProtectorType) -join ', '
                    CapacityGB        = [math]::Round($v.CapacityGB, 2)
                    ComputerName      = $env:COMPUTERNAME
                }
            }
            $results
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $DriveLetter
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential)
            {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else
        {
            $result = &$scriptBlock -MountPoint $DriveLetter
        }

        Write-Output ($result | Sort-Object MountPoint)
    }
    catch
    {
        throw
    }
}
