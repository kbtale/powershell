#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Creates a new IP route in the routing table

.DESCRIPTION
    Adds a new static route to the routing table on a local or remote computer.

.PARAMETER DestinationPrefix
    Specifies the destination prefix of the route (e.g., "192.168.10.0/24").

.PARAMETER NextHop
    Specifies the IP address of the next hop (gateway) for this route.

.PARAMETER InterfaceAlias
    Specifies the friendly name of the network interface to use.

.PARAMETER RouteMetric
    Specifies the integer metric for the route.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./New-NetworkRoute.ps1 -DestinationPrefix "10.0.0.0/8" -NextHop "192.168.1.1" -InterfaceAlias "Ethernet"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$DestinationPrefix,

    [Parameter(Mandatory = $true)]
    [string]$NextHop,

    [Parameter(Mandatory = $true)]
    [string]$InterfaceAlias,

    [int]$RouteMetric = 1,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $routeParams = @{
            'DestinationPrefix' = $DestinationPrefix
            'NextHop'           = $NextHop
            'InterfaceAlias'    = $InterfaceAlias
            'RouteMetric'       = $RouteMetric
            'ErrorAction'       = 'Stop'
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
            $routeParams.Add('CimSession', $session)
        }

        New-NetRoute @routeParams

        $result = [PSCustomObject]@{
            DestinationPrefix = $DestinationPrefix
            NextHop           = $NextHop
            InterfaceAlias    = $InterfaceAlias
            ComputerName      = $ComputerName
            Action            = "RouteCreated"
            Status            = "Success"
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
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
