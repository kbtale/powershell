#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Removes a key protector from a BitLocker volume

.DESCRIPTION
    Deletes a specific key protector (identified by ID) from a local or remote BitLocker volume.

.PARAMETER MountPoint
    Specifies the drive letter or mount point (e.g., "C:").

.PARAMETER KeyProtectorId
    Specifies the unique ID of the key protector to remove.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Remove-BitLockerKeyProtector.ps1 -MountPoint "C:" -KeyProtectorId "{12345678-..."

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$MountPoint,

    [Parameter(Mandatory = $true)]
    [string]$KeyProtectorId,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Drive, $Id)
            Remove-BitLockerKeyProtector -MountPoint $Drive -KeyProtectorId $Id -Confirm:$false -ErrorAction Stop
            Get-BitLockerVolume -MountPoint $Drive | Select-Object -ExpandProperty KeyProtector
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($MountPoint, $KeyProtectorId)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Drive $MountPoint -Id $KeyProtectorId
        }

        $output = [PSCustomObject]@{
            MountPoint       = $MountPoint
            Status           = "ProtectorRemoved"
            RemainingCount   = if ($result) { $result.Count } else { 0 }
            ComputerName     = $ComputerName
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
