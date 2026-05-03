#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures Credential Security Support Provider (CredSSP)

.DESCRIPTION
    Enables or disables CredSSP authentication on a local or remote machine for client or server roles. CredSSP allows applications to delegate user credentials from a client to a remote server.

.PARAMETER Role
    Specifies whether to configure CredSSP for the Client or Server role.

.PARAMETER Enabled
    Specifies whether to enable or disable CredSSP for the specified role.

.PARAMETER DelegateComputer
    Specifies the servers to which client credentials can be delegated (required for Client role).

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-CredSSPConfigRemote.ps1 -Role Server -Enabled $true

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('Server', 'Client')]
    [string]$Role,

    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [string]$DelegateComputer,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($UserRole, $IsEnabled, $Delegation)
            if ($IsEnabled) {
                $params = @{
                    'Role'        = $UserRole
                    'Force'       = $true
                    'ErrorAction' = 'Stop'
                }
                if ($UserRole -eq 'Client') {
                    if (-not $Delegation) { throw "DelegateComputer is required for Client role" }
                    $params.Add('DelegateComputer', $Delegation)
                }
                Enable-WSManCredSSP @params
            }
            else {
                Disable-WSManCredSSP -Role $UserRole -ErrorAction Stop
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Role, $Enabled, $DelegateComputer)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -UserRole $Role -IsEnabled $Enabled -Delegation $DelegateComputer
        }

        $result = [PSCustomObject]@{
            Role         = $Role
            CredSSPEnabled = $Enabled
            ComputerName = $ComputerName
            Action       = "CredSSPConfigured"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
