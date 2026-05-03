#Requires -Version 5.1
#Requires -Modules NetSecurity

<#
.SYNOPSIS
    Windows: Creates a new inbound or outbound firewall rule

.DESCRIPTION
    Configures a new Windows Firewall rule with specified parameters including direction, action, ports, and protocols. Supports remote creation via CIM sessions.

.PARAMETER DisplayName
    Specifies the friendly name of the firewall rule.

.PARAMETER Direction
    Specifies if the rule applies to Inbound or Outbound traffic.

.PARAMETER Action
    Specifies whether to Allow or Block the traffic.

.PARAMETER Protocol
    Specifies the network protocol (e.g., TCP, UDP, ICMPv4).

.PARAMETER LocalPort
    Specifies the local port or port range (e.g., "80", "443", "5000-5005").

.PARAMETER Program
    Specifies the path to the program file to which the rule applies.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./New-FirewallRule.ps1 -DisplayName "Web Server" -Direction Inbound -Protocol TCP -LocalPort 80

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Inbound', 'Outbound')]
    [string]$Direction,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Allow', 'Block')]
    [string]$Action,

    [string]$Protocol,

    [string[]]$LocalPort,

    [string]$Program,

    [string]$Description,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $ruleParams = @{
            'DisplayName' = $DisplayName
            'Direction'   = $Direction
            'Action'      = $Action
            'Enabled'     = 'True'
            'ErrorAction' = 'Stop'
        }

        if (-not [string]::IsNullOrWhiteSpace($Protocol)) { $ruleParams.Add('Protocol', $Protocol) }
        if ($null -ne $LocalPort) { $ruleParams.Add('LocalPort', $LocalPort) }
        if (-not [string]::IsNullOrWhiteSpace($Program)) { $ruleParams.Add('Program', $Program) }
        if (-not [string]::IsNullOrWhiteSpace($Description)) { $ruleParams.Add('Description', $Description) }

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
            $ruleParams.Add('CimSession', $session)
        }

        Write-Verbose "Creating firewall rule '$DisplayName' on '$ComputerName'..."
        $rule = New-NetFirewallRule @ruleParams

        $result = [PSCustomObject]@{
            DisplayName  = $rule.DisplayName
            Direction    = $rule.Direction
            Action       = $rule.Action
            Enabled      = $rule.Enabled
            ComputerName = $ComputerName
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

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
