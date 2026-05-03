#Requires -Version 5.1
#Requires -Modules BitLocker

<#
.SYNOPSIS
    Windows: Backs up a BitLocker key protector to AD DS or AAD

.DESCRIPTION
    Escalates a BitLocker recovery key protector to Active Directory Domain Services or Azure Active Directory.

.PARAMETER MountPoint
    Specifies the drive letter or mount point (e.g., "C:").

.PARAMETER KeyProtectorId
    Specifies the unique ID of the key protector to back up.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Backup-BitLockerKeyProtector.ps1 -MountPoint "C:" -KeyProtectorId "{12345678-..."

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
            Backup-BitLockerKeyProtector -MountPoint $Drive -KeyProtectorId $Id -ErrorAction Stop
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

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -Drive $MountPoint -Id $KeyProtectorId
        }

        $output = [PSCustomObject]@{
            MountPoint     = $MountPoint
            KeyProtectorId = $KeyProtectorId
            Status         = "BackupInitiated"
            ComputerName   = $ComputerName
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
