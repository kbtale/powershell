#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures Advanced Session Mode on a Hyper-V host

.DESCRIPTION
    Enables or disables Enhanced Session Mode for virtual machines on a specified Microsoft Hyper-V host.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Enabled
    Specifies whether Enhanced Session Mode should be enabled ($true) or disabled ($false).

.EXAMPLE
    PS> ./Set-HyperVAdvancedSessionMode.ps1 -Enabled $true

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [bool]$Enabled
)

Process {
    try {
        $params = @{
            'ComputerName'              = $ComputerName
            'EnableEnhancedSessionMode' = $Enabled
            'Confirm'                   = $false
            'ErrorAction'               = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        Set-VMHost @params

        $hostInfo = Get-VMHost -ComputerName $ComputerName -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            ComputerName              = $hostInfo.Name
            EnhancedSessionModeEnabled = $hostInfo.EnableEnhancedSessionMode
            Action                    = "AdvancedSessionModeConfigured"
            Status                    = "Success"
            Timestamp                 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
