#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Forces DNS registration of all IP addresses on a computer

.DESCRIPTION
    Triggers a dynamic DNS update for all network adapters on a local or remote system. This ensures the DNS server has the most current IP address information for the host.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Register-DnsClientRemote.ps1 -ComputerName "WS01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
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
            Register-DnsClient -CimSession $session -ErrorAction Stop
        }
        else {
            Register-DnsClient -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            ComputerName = $ComputerName
            Action       = "DnsRegistrationInitiated"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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
