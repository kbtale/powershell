#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures VM automatic stop action

.DESCRIPTION
    Configures the action a Microsoft Hyper-V virtual machine should take when the host shuts down.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Action
    Specifies the action to take (Save, TurnOff, or ShutDown).

.EXAMPLE
    PS> ./Set-HyperVVMAutomaticStop.ps1 -Name "AppSrv" -Action ShutDown

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Save', 'TurnOff', 'ShutDown')]
    [string]$Action
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

        Set-VM -VM $vm -AutomaticStopAction $Action -ErrorAction Stop

        $result = [PSCustomObject]@{
            Name                = $vm.Name
            AutomaticStopAction = $Action
            Action              = "AutomaticStopUpdated"
            Status              = "Success"
            Timestamp           = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
