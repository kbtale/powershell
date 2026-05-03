#Requires -Version 5.1
#Requires -Modules SmbShare

<#
.SYNOPSIS
    Windows: Creates a new SMB file share and configures permissions

.DESCRIPTION
    Creates a new file share on a local or remote computer. This script also allows for granular permission management during creation, including Full Control, Change, and Read access for specified accounts.

.PARAMETER Name
    Specifies the name of the new share.

.PARAMETER Path
    Specifies the local path of the folder to be shared. The folder must exist on the target system.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Description
    Specifies an optional description for the share.

.PARAMETER FullAccess
    Specifies accounts (e.g., "DOMAIN\User") to be granted Full Control permissions.

.PARAMETER ChangeAccess
    Specifies accounts to be granted Change (Modify) permissions.

.PARAMETER ReadAccess
    Specifies accounts to be granted Read-only permissions.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./New-FileShare.ps1 -Name "Backups" -Path "D:\Backups" -FullAccess "Administrators" -ReadAccess "BackupUsers"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$Description,

    [string[]]$FullAccess,

    [string[]]$ChangeAccess,

    [string[]]$ReadAccess,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $cimParams = @{
            'ErrorAction' = 'Stop'
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $sessionParams = @{
                'ComputerName' = $ComputerName
            }
            if ($null -ne $Credential)
            {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            $cimParams.Add('CimSession', $session)
        }

        $newShareParams = @{
            'Name'        = $Name
            'Path'        = $Path
            'Description' = $Description
            'ErrorAction' = 'Stop'
        }

        if ($null -ne $FullAccess) { $newShareParams.Add('FullAccess', $FullAccess) }
        if ($null -ne $ChangeAccess) { $newShareParams.Add('ChangeAccess', $ChangeAccess) }
        if ($null -ne $ReadAccess) { $newShareParams.Add('ReadAccess', $ReadAccess) }

        New-SmbShare @newShareParams @cimParams | Out-Null

        $result = Get-SmbShare -Name $Name @cimParams | Select-Object Name, Path, Description
        Write-Output $result
    }
    catch
    {
        throw
    }
    finally
    {
        if ($null -ne $session)
        {
            Remove-CimSession $session
        }
    }
}
