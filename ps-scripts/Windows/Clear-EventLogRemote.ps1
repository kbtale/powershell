#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Clears all entries from specified event logs

.DESCRIPTION
    Permanently deletes all events from one or more event logs on a local or remote computer. This script is typically used for log maintenance or after completing a troubleshooting phase.

.PARAMETER LogName
    Specifies the name of the event log to clear (e.g., "Application", "System").

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Clear-EventLogRemote.ps1 -LogName "Application" -ComputerName "SRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]]$LogName,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $clearParams = @{
            'LogName'      = $LogName
            'ComputerName' = $ComputerName
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }

        if ($null -ne $Credential)
        {
            $clearParams.Add('Credential', $Credential)
        }

        Write-Verbose "Clearing event log(s): $($LogName -join ', ') on '$ComputerName'..."
        Clear-EventLog @clearParams

        $result = [PSCustomObject]@{
            LogNames     = $LogName
            ComputerName = $ComputerName
            Action       = "Cleared"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
