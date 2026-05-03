#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Clears the recycle bin for one or more drives

.DESCRIPTION
    Permanently deletes all items in the recycle bin on a local or remote computer. This script can target specific drive letters or clear all recycle bins across the system.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER DriveLetter
    Specifies one or more drive letters (e.g., "C", "D") to clear. If omitted, all recycle bins are cleared.

.PARAMETER Force
    If set, clears the recycle bin without prompting for confirmation.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Clear-RecycleBinRemote.ps1 -Force

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string[]]$DriveLetter,

    [switch]$Force,

    [pscredential]$Credential
)

Process
{
    try
    {
        $clearParams = @{
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($Force)
        {
            $clearParams.Add('Force', $true)
        }

        if ($null -ne $DriveLetter)
        {
            $clearParams.Add('DriveLetter', $DriveLetter)
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = {
                    Param($Params)
                    Clear-RecycleBin @Params
                }
                'ArgumentList' = $clearParams
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential)
            {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else
        {
            Clear-RecycleBin @clearParams
        }

        $result = [PSCustomObject]@{
            ComputerName = $ComputerName
            Action       = "Recycle bin cleared"
            Drives       = if ($null -ne $DriveLetter) { $DriveLetter -join ', ' } else { "All" }
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
