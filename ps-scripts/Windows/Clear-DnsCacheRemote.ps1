#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Clears the DNS client cache on a local or remote computer

.DESCRIPTION
    Flushes the DNS resolver cache. This is useful for troubleshooting DNS resolution issues or ensuring that recent DNS record changes are recognized by the system.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Clear-DnsCacheRemote.ps1 -ComputerName "SRV01"

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
            Clear-DnsClientCache -CimSession $session -ErrorAction Stop
        }
        else {
            Clear-DnsClientCache -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            ComputerName = $ComputerName
            Action       = "DnsCacheCleared"
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
