#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves detailed virtual machine inventory

.DESCRIPTION
    Retrieves an extensive audit of all virtual machines on a specifies Microsoft Hyper-V host, including heartbeats, integration service versions, and generational metadata.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER NamePattern
    Optional. Specifies a wildcard pattern to filter virtual machine names (e.g., "Web*").

.PARAMETER State
    Optional. Specifies the state of virtual machines to retrieve.

.EXAMPLE
    PS> ./Get-HyperVVMDetail.ps1 -NamePattern "PROD-*" -State Running

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [string]$NamePattern = "*",

    [ValidateSet('Running', 'Off', 'Paused', 'Saved', 'Starting', 'Stopping')]
    [string]$State
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'Name'         = $NamePattern
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vms = Get-VM @params
        
        if ($State) {
            $vms = $vms | Where-Object { $_.State -eq $State }
        }

        $results = foreach ($v in $vms) {
            [PSCustomObject]@{
                Name                      = $v.Name
                Id                        = $v.Id
                State                     = $v.State
                Generation                = $v.Generation
                Status                    = $v.Status
                Heartbeat                 = $v.Heartbeat
                IntegrationServiceVersion = $v.IntegrationServicesVersion
                MemoryStartup             = $v.MemoryStartup
                MemoryAssigned            = $v.MemoryAssigned
                ProcessorCount            = $v.ProcessorCount
                Uptime                    = $v.Uptime
                Notes                     = $v.Notes
                Path                      = $v.Path
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
