#Requires -Version 5.1
#Requires -Modules NetTcpIp

<#
.SYNOPSIS
    Windows: Configures a static IP address for a network adapter

.DESCRIPTION
    Sets a static IPv4 address, prefix length, and default gateway for a specified network interface. This script handles the transition from DHCP to static and updates existing static configurations on local or remote systems.

.PARAMETER Name
    Specifies the name or alias of the network adapter to configure.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER IPAddress
    Specifies the static IPv4 address to assign.

.PARAMETER PrefixLength
    Specifies the subnet prefix length (e.g., 24 for 255.255.255.0).

.PARAMETER DefaultGateway
    Specifies the default gateway IP address.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-IPAddressStatic.ps1 -Name "Ethernet" -IPAddress "192.168.1.50" -PrefixLength 24 -DefaultGateway "192.168.1.1"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$IPAddress,

    [Parameter(Mandatory = $true)]
    [int]$PrefixLength,

    [string]$DefaultGateway,

    [string]$ComputerName = $env:COMPUTERNAME,

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

        # Identify the interface
        $interface = Get-NetIPInterface -InterfaceAlias $Name -AddressFamily IPv4 @cimParams
        
        # Remove existing IPv4 addresses to avoid conflicts
        Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4 @cimParams | Remove-NetIPAddress -Confirm:$false @cimParams

        # Configure static IP
        $newAddressParams = @{
            'InterfaceIndex' = $interface.InterfaceIndex
            'IPAddress'      = $IPAddress
            'PrefixLength'   = $PrefixLength
            'AddressFamily'  = 'IPv4'
        }
        if (-not [string]::IsNullOrWhiteSpace($DefaultGateway))
        {
            $newAddressParams.Add('DefaultGateway', $DefaultGateway)
        }
        
        New-NetIPAddress @newAddressParams @cimParams | Out-Null

        # Return the new configuration
        $result = Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4 @cimParams | Select-Object InterfaceAlias, IPAddress, PrefixLength, AddressFamily
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
