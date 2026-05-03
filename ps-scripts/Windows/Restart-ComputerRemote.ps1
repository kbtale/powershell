#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Restarts one or more local or remote computers

.DESCRIPTION
    Reboots the operating system on specified computers. This script includes options to wait for the computer to become available after the restart, ensuring that critical services or connectivity are restored before completing.

.PARAMETER ComputerName
    Specifies one or more computer names or IP addresses to restart.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.PARAMETER Force
    Indicates that the restart should be forced even if users are logged on.

.PARAMETER Wait
    Indicates that the script should wait for the computers to restart and become available before finishing.

.PARAMETER Timeout
    Specifies the maximum time (in seconds) to wait for the computer to become available.

.EXAMPLE
    PS> ./Restart-ComputerRemote.ps1 -ComputerName "SRV01", "SRV02" -Force -Wait

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]]$ComputerName,

    [pscredential]$Credential,

    [switch]$Force,

    [switch]$Wait,

    [int]$Timeout = 300
)

Process
{
    try
    {
        $restartParams = @{
            'ComputerName' = $ComputerName
            'Force'        = $Force
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }

        if ($null -ne $Credential)
        {
            $restartParams.Add('Credential', $Credential)
        }

        if ($Wait)
        {
            $restartParams.Add('Wait', $true)
            $restartParams.Add('For', 'Wmi')
            $restartParams.Add('Timeout', $Timeout)
        }

        Write-Verbose "Initiating restart for: $($ComputerName -join ', ')"
        Restart-Computer @restartParams

        $result = [PSCustomObject]@{
            Computers = $ComputerName
            Action    = "Restart"
            Status    = if ($Wait) { "Completed (Available)" } else { "Initiated" }
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
