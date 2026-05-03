#Requires -Version 5.1
#Requires -Modules SmbShare

<#
.SYNOPSIS
    Windows: Retrieves information about SMB file shares

.DESCRIPTION
    Lists one or all file shares on a local or remote computer. This script provides details on the share path, description, current user count, and share type (e.g., FileSystemDirectory, IPC). Supports hidden shares and remote auditing via CIM.

.PARAMETER Name
    Specifies the name of the share to retrieve. Supports wildcards.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER IncludeHidden
    If set, includes hidden (administrative) shares like C$, ADMIN$, etc.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-FileShareInfo.ps1 -IncludeHidden

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$Name,

    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$IncludeHidden,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $shareParams = @{
            'ErrorAction' = 'Stop'
        }

        if ($IncludeHidden)
        {
            $shareParams.Add('IncludeHidden', $true)
        }

        if (-not [string]::IsNullOrWhiteSpace($Name))
        {
            $shareParams.Add('Name', $Name)
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
            $shareParams.Add('CimSession', $session)
        }

        $shares = Get-SmbShare @shareParams

        $results = foreach ($share in $shares)
        {
            [PSCustomObject]@{
                Name         = $share.Name
                Path         = $share.Path
                Description  = $share.Description
                Status       = $share.ShareState
                Type         = $share.ShareType
                CurrentUsers = $share.CurrentUsers
                Scoped       = $share.Scoped
                ComputerName = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object Name)
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
