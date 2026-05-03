#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Retrieves DNS client configuration for network interfaces

.DESCRIPTION
    Gets the DNS client settings for all or specified network interfaces on a local or remote computer. This includes interface aliases, indices, and connection-specific DNS suffixes.

.PARAMETER InterfaceAlias
    Specifies the friendly name of the interface (e.g., "Ethernet"). Supports wildcards.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-DnsClientInfo.ps1 -InterfaceAlias "Wi-Fi"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$InterfaceAlias = "*",

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $dnsParams = @{
            'ErrorAction' = 'Stop'
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
            $dnsParams.Add('CimSession', $session)
        }

        $clients = Get-DnsClient @dnsParams | Where-Object { $_.InterfaceAlias -like $InterfaceAlias }

        $results = foreach ($c in $clients) {
            [PSCustomObject]@{
                InterfaceAlias      = $c.InterfaceAlias
                InterfaceIndex      = $c.InterfaceIndex
                ConnectionSpecificSuffix = $c.ConnectionSpecificSuffix
                RegisterThisAddr    = $c.RegisterThisConnectionsAddress
                UseSuffixInReg      = $c.UseSuffixWhenRegistering
                ComputerName        = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object InterfaceAlias)
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
