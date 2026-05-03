#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Manages the power state of a virtual machine

.DESCRIPTION
    Performs power state operations on a specifies Microsoft Hyper-V virtual machine, including starting, stopping, restarting, suspending, resuming, and saving.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Action
    Specifies the power state action to perform (Start, Stop, Suspend, Resume, Restart, TurnOff, Save).

.PARAMETER Force
    If set, forces the operation (e.g., for Stop or Restart).

.EXAMPLE
    PS> ./Set-HyperVVMState.ps1 -Name "AppSrv-01" -Action Start

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Start', 'Stop', 'Suspend', 'Resume', 'Restart', 'TurnOff', 'Save')]
    [string]$Action,

    [switch]$Force
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

        switch ($Action) {
            'Start'    { Start-VM -VM $vm }
            'Stop'     { Stop-VM -VM $vm -Force:$Force -Confirm:(-not $Force) }
            'TurnOff'  { Stop-VM -VM $vm -TurnOff }
            'Save'     { Stop-VM -VM $vm -Save }
            'Suspend'  { Suspend-VM -VM $vm }
            'Resume'   { Resume-VM -VM $vm }
            'Restart'  { Restart-VM -VM $vm -Force:$Force -Confirm:(-not $Force) }
        }

        $result = [PSCustomObject]@{
            Name      = $vm.Name
            Action    = $Action
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
