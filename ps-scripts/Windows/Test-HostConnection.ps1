#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Tests network connectivity and service availability for hosts

.DESCRIPTION
    Sends ICMP echo requests (pings) and optionally tests for basic remote management availability (WinRM/RPC). This script provides a comprehensive connectivity report for one or more target systems.

.PARAMETER ComputerName
    Specifies one or more computer names or IP addresses to test.

.PARAMETER Count
    Specifies the number of echo requests to send (Defaults to 4).

.PARAMETER TestService
    If set, attempts to verify if core management services (WinRM or RPC) are responsive.

.EXAMPLE
    PS> ./Test-HostConnection.ps1 -ComputerName "SRV01", "192.168.1.10"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]]$ComputerName,

    [int]$Count = 4,

    [switch]$TestService
)

Process
{
    try
    {
        $results = foreach ($c in $ComputerName)
        {
            $ping = Test-Connection -ComputerName $c -Count $Count -Quiet -ErrorAction SilentlyContinue
            
            $serviceStatus = "Not Tested"
            if ($TestService -and $ping)
            {
                if (Test-NetConnection -ComputerName $c -Port 5985 -InformationLevel Quiet -ErrorAction SilentlyContinue)
                {
                    $serviceStatus = "WinRM Available"
                }
                elseif (Test-NetConnection -ComputerName $c -Port 135 -InformationLevel Quiet -ErrorAction SilentlyContinue)
                {
                    $serviceStatus = "RPC Available"
                }
                else
                {
                    $serviceStatus = "Management Ports Closed"
                }
            }

            [PSCustomObject]@{
                Target      = $c
                PingSuccess = $ping
                ServiceInfo = $serviceStatus
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch
    {
        throw
    }
}
