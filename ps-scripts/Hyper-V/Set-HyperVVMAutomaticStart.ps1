#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures VM automatic start action

.DESCRIPTION
    Configures the action a Microsoft Hyper-V virtual machine should take when the host starts, and sets the startup delay.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Action
    Specifies the action to take (Nothing, StartIfRunning, or Start).

.PARAMETER DelaySeconds
    Optional. Specifies the delay in seconds before the virtual machine starts.

.EXAMPLE
    PS> ./Set-HyperVVMAutomaticStart.ps1 -Name "MailSrv" -Action Start -DelaySeconds 60

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Nothing', 'StartIfRunning', 'Start')]
    [string]$Action,

    [int]$DelaySeconds = 0
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vm = Get-VM @params | Where-Object { $_.Name -eq $Name -or $_.Id -eq $Name }

        if (-not $vm) {
            throw "Virtual machine '$Name' not found on '$ComputerName'."
        }

        Set-VM -VM $vm -AutomaticStartAction $Action -AutomaticStartDelay $DelaySeconds -ErrorAction Stop

        $result = [PSCustomObject]@{
            Name                 = $vm.Name
            AutomaticStartAction = $Action
            AutomaticStartDelay  = $DelaySeconds
            Action               = "AutomaticStartUpdated"
            Status               = "Success"
            Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
