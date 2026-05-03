#Requires -Version 5.1
#Requires -Modules NetSecurity

<#
.SYNOPSIS
    Windows: Modifies an existing firewall rule

.DESCRIPTION
    Updates properties of an existing Windows Firewall rule, such as its state (Enabled/Disabled), action (Allow/Block), or display name. Supports local and remote configuration via CIM.

.PARAMETER Name
    Specifies the name or display name of the firewall rule to modify.

.PARAMETER Enabled
    Specifies whether the rule should be Enabled or Disabled.

.PARAMETER Action
    Specifies the action to take (Allow or Block).

.PARAMETER NewDisplayName
    Specifies a new display name for the rule.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-FirewallRuleConfig.ps1 -Name "Web Server" -Enabled False

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet('True', 'False')]
    [string]$Enabled,

    [ValidateSet('Allow', 'Block')]
    [string]$Action,

    [string]$NewDisplayName,

    [string]$Description,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $session = $null
        $cimParams = @{
            'ErrorAction' = 'Stop'
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
            $cimParams.Add('CimSession', $session)
        }

        # Find the rule first to handle display names vs internal names
        $rule = Get-NetFirewallRule @cimParams | Where-Object { $_.DisplayName -eq $Name -or $_.Name -eq $Name } | Select-Object -First 1

        if ($null -eq $rule)
        {
            throw "Firewall rule '$Name' not found on '$ComputerName'."
        }

        $setParams = @{
            'InputObject' = $rule
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('Enabled')) { $setParams.Add('Enabled', $Enabled) }
        if ($PSBoundParameters.ContainsKey('Action')) { $setParams.Add('Action', $Action) }
        if ($PSBoundParameters.ContainsKey('NewDisplayName')) { $setParams.Add('NewDisplayName', $NewDisplayName) }
        if ($PSBoundParameters.ContainsKey('Description')) { $setParams.Add('Description', $Description) }

        Write-Verbose "Updating firewall rule '$Name' on '$ComputerName'..."
        Set-NetFirewallRule @setParams @cimParams

        $updatedRule = Get-NetFirewallRule -Name $rule.Name @cimParams
        $result = [PSCustomObject]@{
            Name         = $updatedRule.DisplayName
            Enabled      = $updatedRule.Enabled
            Action       = $updatedRule.Action
            ComputerName = $ComputerName
            Status       = "Updated"
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
