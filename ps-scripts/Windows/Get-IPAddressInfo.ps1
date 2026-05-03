#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Retrieves IP address configuration for network adapters

.DESCRIPTION
    Gets detailed IP address information (IPv4 and IPv6) for all or specified network interfaces on a local or remote computer.

.PARAMETER InterfaceAlias
    Specifies the friendly name of the network interface (e.g., "Ethernet"). Supports wildcards.

.PARAMETER AddressFamily
    Specifies the IP address family. Valid values: IPv4, IPv6.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-IPAddressInfo.ps1 -AddressFamily IPv4

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$InterfaceAlias = "*",

    [ValidateSet('IPv4', 'IPv6')]
    [string]$AddressFamily,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $ipParams = @{
            'ErrorAction' = 'Stop'
        }
        if (-not [string]::IsNullOrWhiteSpace($AddressFamily)) {
            $ipParams.Add('AddressFamily', $AddressFamily)
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $sessionParams = @{
                'ComputerName' = $ComputerName
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            $ipParams.Add('CimSession', $session)
        }

        $addresses = Get-NetIPAddress @ipParams | Where-Object { $_.InterfaceAlias -like $InterfaceAlias }

        $results = foreach ($addr in $addresses) {
            [PSCustomObject]@{
                InterfaceAlias = $addr.InterfaceAlias
                IPAddress      = $addr.IPAddress
                AddressFamily  = $addr.AddressFamily
                PrefixLength   = $addr.PrefixLength
                Type           = $addr.Type
                ComputerName   = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object InterfaceAlias, IPAddress)
    }
    catch {
        throw
    }
    finally {
        if ($null -ne $session) {
            Remove-CimSession $session
        }
    }
}
