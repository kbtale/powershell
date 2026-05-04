#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Generates a consolidated virtual machine inventory report

.DESCRIPTION
    Retrieves a comprehensive inventory of all virtual machines on a Microsoft Hyper-V host, including operational states, CPU usage, and memory demand.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER State
    Optional. Filters virtual machines by their current operational state.

.EXAMPLE
    PS> ./Get-HyperVVMInventoryReport.ps1 -State Running

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [ValidateSet('All', 'Running', 'Off', 'Stopping', 'Saved', 'Paused', 'Starting', 'Reset', 'Saving', 'Pausing', 'Resuming',
        'FastSaved', 'FastSaving', 'RunningCritical', 'OffCritical', 'StoppingCritical', 'SavedCritical', 'PausedCritical',
        'StartingCritical', 'ResetCritical', 'SavingCritical', 'PausingCritical', 'ResumingCritical', 'FastSavedCritical',
        'FastSavingCritical', 'Other')]
    [string]$State = "All"
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vms = Get-VM @params

        if ($State -ne "All") {
            $vms = $vms | Where-Object { $_.State -eq $State }
        }

        $results = foreach ($vm in $vms) {
            [PSCustomObject]@{
                VMName           = $vm.Name
                State            = $vm.State
                CPUUsage         = $vm.CPUUsage
                MemoryAssignedMB = [math]::Round($vm.MemoryAssigned / 1MB, 2)
                MemoryDemandMB   = [math]::Round($vm.MemoryDemand / 1MB, 2)
                Status           = $vm.Status
                Uptime           = $vm.Uptime
                Generation       = $vm.Generation
                Version          = $vm.Version
                ComputerName     = $vm.ComputerName
            }
        }

        Write-Output ($results | Sort-Object VMName)
    }
    catch {
        throw
    }
}
