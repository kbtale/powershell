#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Enables or disables Remote Desktop (RDP) connections

.DESCRIPTION
    Configures the terminal server settings to allow or deny Remote Desktop connections. Optionally manages firewall rules and Network Level Authentication (NLA).

.PARAMETER Enabled
    Specifies whether to enable or disable RDP.

.PARAMETER RequireNLA
    If set, requires Network Level Authentication for connections.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-RemoteDesktopConfig.ps1 -Enabled $true -RequireNLA $true

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [bool]$RequireNLA = $true,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($IsEnabled, $UseNLA)
            $denyValue = if ($IsEnabled) { 0 } else { 1 }
            $nlaValue = if ($UseNLA) { 1 } else { 0 }
            
            $tsPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server"
            $winStationPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
            
            Set-ItemProperty -Path $tsPath -Name "fDenyTSConnections" -Value $denyValue -Force -ErrorAction Stop
            Set-ItemProperty -Path $winStationPath -Name "UserAuthentication" -Value $nlaValue -Force -ErrorAction Stop
            
            if ($IsEnabled) {
                Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
            }
            else {
                Disable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Enabled, $RequireNLA)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -IsEnabled $Enabled -UseNLA $RequireNLA
        }

        $result = [PSCustomObject]@{
            RDPEnabled   = $Enabled
            RequireNLA   = $RequireNLA
            ComputerName = $ComputerName
            Action       = "RemoteDesktopConfigured"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
