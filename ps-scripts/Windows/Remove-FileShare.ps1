#Requires -Version 5.1
#Requires -Modules SmbShare

<#
.SYNOPSIS
    Windows: Removes an existing SMB file share

.DESCRIPTION
    Deletes a specified file share from the local or remote computer. This operation only removes the share configuration; the underlying folder and files are preserved. Supports forced removal and remote execution via CIM.

.PARAMETER Name
    Specifies the name of the share to remove.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Force
    Indicates that the share should be removed even if there are active connections or open files.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Remove-FileShare.ps1 -Name "TempShare" -Force

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Name,

    [string]$ComputerName = $env:COMPUTERNAME,

    [switch]$Force,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $removeParams = @{
            'Name'        = $Name
            'Force'       = $Force
            'Confirm'     = $false
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
            $removeParams.Add('CimSession', $session)
        }

        Write-Verbose "Attempting to remove share '$Name' from '$ComputerName'..."
        Remove-SmbShare @removeParams

        $result = [PSCustomObject]@{
            ShareName    = $Name
            ComputerName = $ComputerName
            Action       = "Removed"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

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
