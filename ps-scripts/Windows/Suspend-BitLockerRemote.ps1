#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Suspends BitLocker protection on a specified volume

.DESCRIPTION
    Temporarily suspends BitLocker encryption protection. This is often required before updating BIOS, firmware, or hardware components.

.PARAMETER MountPoint
    Specifies the drive letter or mount point of the volume (e.g., "C:").

.PARAMETER RebootCount
    Specifies the number of reboots after which protection is automatically resumed. Valid range: 0 to 15. A value of 0 suspends protection indefinitely.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Suspend-BitLockerRemote.ps1 -MountPoint "C:" -RebootCount 1

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$MountPoint,

    [ValidateRange(0, 15)]
    [int]$RebootCount = 0,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Drive, $Count)
            Suspend-BitLocker -MountPoint $Drive -RebootCount $Count -Confirm:$false -ErrorAction Stop
            Get-BitLockerVolume -MountPoint $Drive | Select-Object MountPoint, ProtectionStatus
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($MountPoint, $RebootCount)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Drive $MountPoint -Count $RebootCount
        }

        $output = [PSCustomObject]@{
            MountPoint       = $result.MountPoint
            ProtectionStatus = $result.ProtectionStatus
            RebootCount      = $RebootCount
            ComputerName     = $ComputerName
            Action           = "ProtectionSuspended"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
