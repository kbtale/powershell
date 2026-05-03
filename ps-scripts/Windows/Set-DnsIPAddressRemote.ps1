#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Configures static DNS server addresses for an adapter

.DESCRIPTION
    Sets specific DNS server IP addresses for a network interface on a local or remote computer. Overwrites any existing static DNS configuration.

.PARAMETER InterfaceAlias
    Specifies the friendly name of the network interface (e.g., "Ethernet").

.PARAMETER DnsServers
    Specifies an array of DNS server IP addresses to configure.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-DnsIPAddressRemote.ps1 -InterfaceAlias "Ethernet" -DnsServers "8.8.8.8", "8.8.4.4"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$InterfaceAlias,

    [Parameter(Mandatory = $true)]
    [string[]]$DnsServers,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        if ($ComputerName -ne $env:COMPUTERNAME) {
            $sessionParams = @{
                'ComputerName' = $ComputerName
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            Set-DnsClientServerAddress -CimSession $session -InterfaceAlias $InterfaceAlias -ServerAddresses $DnsServers -ErrorAction Stop
        }
        else {
            Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DnsServers -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            InterfaceAlias = $InterfaceAlias
            DnsServers     = $DnsServers -join ", "
            ComputerName   = $ComputerName
            Action         = "DnsServersConfigured"
            Status         = "Success"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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
