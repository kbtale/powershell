#Requires -Version 5.1
#Requires -Modules NetAdapter, NetTcpIp

<#
.SYNOPSIS
    Windows: Retrieves detailed network adapter and IP configuration

.DESCRIPTION
    Consolidates information from network adapters and their assigned IP addresses into a single structured report. This script provides details on physical status, link speed, MAC addresses, and both IPv4/IPv6 configurations for local or remote systems.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Name
    Specifies the name or alias of a specific network adapter to retrieve.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-NetworkAdapterInfo.ps1 -Name "Ethernet*"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$Name,

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

        $adapters = Get-NetAdapter @cimParams
        if (-not [string]::IsNullOrWhiteSpace($Name))
        {
            $adapters = $adapters | Where-Object { $_.Name -like $Name -or $_.InterfaceAlias -like $Name }
        }

        $results = foreach ($adapter in $adapters)
        {
            $ipAddresses = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex @cimParams
            
            [PSCustomObject]@{
                Name           = $adapter.Name
                InterfaceAlias = $adapter.InterfaceAlias
                Status         = $adapter.Status
                LinkSpeed      = $adapter.LinkSpeed
                MacAddress     = $adapter.MacAddress
                IPv4Address    = ($ipAddresses | Where-Object { $_.AddressFamily -eq 'IPv4' }).IPAddress -join ', '
                IPv6Address    = ($ipAddresses | Where-Object { $_.AddressFamily -eq 'IPv6' }).IPAddress -join ', '
                DHCP           = (Get-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex @cimParams | Where-Object { $_.AddressFamily -eq 'IPv4' }).Dhcp
                ComputerName   = $ComputerName
            }
        }

        Write-Output $results
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
