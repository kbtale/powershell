#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Resumes BitLocker protection on a specified volume

.DESCRIPTION
    Restores BitLocker encryption protection on a volume that was previously suspended.

.PARAMETER MountPoint
    Specifies the drive letter or mount point of the volume (e.g., "C:").

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Resume-BitLockerRemote.ps1 -MountPoint "C:"

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
            Resume-BitLocker -MountPoint $Drive -Confirm:$false -ErrorAction Stop
            Get-BitLockerVolume -MountPoint $Drive | Select-Object MountPoint, ProtectionStatus
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
            ProtectionStatus = $result.ProtectionStatus
            ComputerName     = $ComputerName
            Action           = "ProtectionResumed"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
