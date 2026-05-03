#Requires -Version 5.1
#Requires -Modules NetSecurity

<#
.SYNOPSIS
    Windows: Retrieves detailed firewall rule configuration

.DESCRIPTION
    Lists active and inactive firewall rules on a local or remote computer. This script provides an audit-ready view of security policies, including ports, protocols, profiles, and action states (Allow/Block).

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Name
    Specifies the display name or internal name of the rule to retrieve. Supports wildcards.

.PARAMETER EnabledOnly
    If set, only retrieves rules that are currently enabled.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-FirewallRuleInfo.ps1 -Name "Remote Desktop*"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$Name = "*",

    [switch]$EnabledOnly,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $ruleParams = @{
            'ErrorAction' = 'Stop'
        }

        if ($EnabledOnly)
        {
            $ruleParams.Add('Enabled', 'True')
        }

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

        $rules = Get-NetFirewallRule @ruleParams | Where-Object { $_.DisplayName -like $Name -or $_.Name -like $Name }

        $results = foreach ($rule in $rules)
        {
            # Get port details (requires Get-NetFirewallPortFilter)
            $ports = $rule | Get-NetFirewallPortFilter @ruleParams -ErrorAction SilentlyContinue
            
            [PSCustomObject]@{
                DisplayName  = $rule.DisplayName
                Group        = $rule.Group
                Enabled      = $rule.Enabled
                Profile      = $rule.Profile
                Direction    = $rule.Direction
                Action       = $rule.Action
                LocalPort    = if ($ports) { $ports.LocalPort } else { "Any" }
                Protocol     = if ($ports) { $ports.Protocol } else { "Any" }
                ComputerName = $ComputerName
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
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
