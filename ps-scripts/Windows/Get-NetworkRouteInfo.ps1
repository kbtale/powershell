#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Retrieves the IP routing table from a computer

.DESCRIPTION
    Lists all IP routes in the routing table of a local or remote computer. Supports filtering by destination prefix and address family.

.PARAMETER DestinationPrefix
    Specifies the destination prefix of the route (e.g., "0.0.0.0/0"). Supports wildcards.

.PARAMETER AddressFamily
    Specifies the IP address family. Valid values: IPv4, IPv6.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-NetworkRouteInfo.ps1 -AddressFamily IPv4

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$DestinationPrefix = "*",

    [ValidateSet('IPv4', 'IPv6')]
    [string]$AddressFamily,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $routeParams = @{
            'ErrorAction' = 'Stop'
        }
        if (-not [string]::IsNullOrWhiteSpace($AddressFamily)) {
            $routeParams.Add('AddressFamily', $AddressFamily)
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

        $routes = Get-NetRoute @routeParams | Where-Object { $_.DestinationPrefix -like $DestinationPrefix }

        $results = foreach ($r in $routes) {
            [PSCustomObject]@{
                DestinationPrefix = $r.DestinationPrefix
                NextHop           = $r.NextHop
                InterfaceAlias    = $r.InterfaceAlias
                RouteMetric       = $r.RouteMetric
                Protocol          = $r.Protocol
                ComputerName      = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object DestinationPrefix)
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
