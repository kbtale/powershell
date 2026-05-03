#Requires -Version 5.1
#Requires -Modules DnsClient

<#
.SYNOPSIS
    Windows: Retrieves DNS client and server configuration

.DESCRIPTION
    Audits the DNS server addresses and client settings for network interfaces. This script provides visibility into which DNS servers (IPv4/IPv6) are configured for each active adapter on local or remote systems.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER InterfaceAlias
    Specifies the alias of a specific network interface to query.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-DnsClientServer.ps1 -ComputerName "SRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$InterfaceAlias,

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

        $interfaces = Get-DnsClient @cimParams
        if (-not [string]::IsNullOrWhiteSpace($InterfaceAlias))
        {
            $interfaces = $interfaces | Where-Object { $_.InterfaceAlias -like $InterfaceAlias }
        }

        $results = foreach ($interface in $interfaces)
        {
            $serverAddresses = Get-DnsClientServerAddress -InterfaceIndex $interface.InterfaceIndex @cimParams
            
            [PSCustomObject]@{
                InterfaceAlias = $interface.InterfaceAlias
                InterfaceIndex = $interface.InterfaceIndex
                DNSServers     = ($serverAddresses.ServerAddresses) -join ', '
                RegisterSuffix = $interface.RegisterThisConnectionsAddress
                SuffixSearch   = ($interface.ConnectionSpecificSuffix)
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
