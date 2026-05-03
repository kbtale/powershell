#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Lists all virtual machines on a host

.DESCRIPTION
    Retrieves an inventory of all virtual machines on a specified Microsoft Hyper-V host. Supports filtering by VM state.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER State
    Optional. Specifies the state of virtual machines to retrieve (e.g., Running, Off, Paused).

.EXAMPLE
    PS> ./Get-HyperVVM.ps1 -State Running

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [ValidateSet('Running', 'Off', 'Paused', 'Saved', 'Starting', 'Stopping')]
    [string]$State
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vms = Get-VM @params
        
        if ($State) {
            $vms = $vms | Where-Object { $_.State -eq $State }
        }

        $results = foreach ($v in $vms) {
            [PSCustomObject]@{
                Name           = $v.Name
                State          = $v.State
                Status         = $v.Status
                MemoryAssigned = $v.MemoryAssigned
                CPUUsage       = $v.CPUUsage
                Uptime         = $v.Uptime
                ComputerName   = $v.ComputerName
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
