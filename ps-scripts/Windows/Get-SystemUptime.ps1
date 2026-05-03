#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Calculates the system uptime and last boot time

.DESCRIPTION
    Retrieves the system boot time from the operating system and calculates the elapsed time (uptime). Supports local and remote computers via CIM.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-SystemUptime.ps1 -ComputerName "SRV-FILE-01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $cimParams = @{
            'ClassName'   = 'Win32_OperatingSystem'
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

        $os = Get-CimInstance @cimParams | Select-Object -First 1
        
        $bootTime = $os.LastBootUpTime
        $uptime = New-TimeSpan -Start $bootTime -End (Get-Date)

        $result = [PSCustomObject]@{
            LastBootTime = $bootTime
            UptimeDays   = $uptime.Days
            UptimeHours  = $uptime.Hours
            UptimeMinutes = $uptime.Minutes
            UptimeString = "$($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
            ComputerName = $ComputerName
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
