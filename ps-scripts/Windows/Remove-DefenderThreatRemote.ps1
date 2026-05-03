#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Removes active threats detected by Windows Defender

.DESCRIPTION
    Triggers the removal or remediation of all active threats on a local or remote computer.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Remove-DefenderThreatRemote.ps1 -ComputerName "SRV01"

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
            Remove-MpThreat -CimSession $session -ErrorAction Stop
        }
        else {
            Remove-MpThreat -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            ComputerName = $ComputerName
            Action       = "ActiveThreatsRemoved"
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
