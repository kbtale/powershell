#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Resets DNS server addresses to default for a specified adapter

.DESCRIPTION
    Reverts the DNS server configuration for a specific network adapter to its default state (usually DHCP-assigned). Works on local and remote computers.

.PARAMETER InterfaceAlias
    Specifies the friendly name of the network interface (e.g., "Ethernet").

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Reset-DnsConfigRemote.ps1 -InterfaceAlias "Ethernet"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$InterfaceAlias,

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
            Set-DnsClientServerAddress -CimSession $session -InterfaceAlias $InterfaceAlias -ResetServerAddresses -ErrorAction Stop
        }
        else {
            Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ResetServerAddresses -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            InterfaceAlias = $InterfaceAlias
            ComputerName   = $ComputerName
            Action         = "DnsResetToDefault"
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
