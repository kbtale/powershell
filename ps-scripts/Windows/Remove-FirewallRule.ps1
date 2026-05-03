#Requires -Version 5.1
#Requires -Modules NetSecurity

<#
.SYNOPSIS
    Windows: Removes an existing firewall rule

.DESCRIPTION
    Permanently deletes a specified firewall rule from the local or remote computer. Supports identification by name or display name and remote execution via CIM.

.PARAMETER Name
    Specifies the name or display name of the firewall rule to remove.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Remove-FirewallRule.ps1 -Name "Temp Web Rule"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Name,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        $cimParams = @{
            'ErrorAction' = 'Stop'
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $sessionParams = @{
                'ComputerName' = $ComputerName
            }
            if ($null -ne $Credential) {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            $cimParams.Add('CimSession', $session)
        }

        $rules = Get-NetFirewallRule @cimParams | Where-Object { $_.DisplayName -eq $Name -or $_.Name -eq $Name }

        if ($null -eq $rules) {
            throw "Firewall rule '$Name' not found on '$ComputerName'."
        }

        foreach ($rule in $rules) {
            Write-Verbose "Removing firewall rule '$($rule.DisplayName)' on '$ComputerName'..."
            Remove-NetFirewallRule -InputObject $rule @cimParams
        }

        $result = [PSCustomObject]@{
            Target       = $Name
            ComputerName = $ComputerName
            Action       = "Removed"
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
