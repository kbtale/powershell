#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Generates a consolidated virtual machine checkpoint report

.DESCRIPTION
    Retrieves a comprehensive list of all checkpoints (snapshots) across all virtual machines on a Microsoft Hyper-V host, including creation times and parentage details.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER CheckpointType
    Optional. Filters checkpoints by type (Standard, Recovery, Planned, etc.).

.EXAMPLE
    PS> ./Get-HyperVVMCheckpointReport.ps1 -CheckpointType Standard

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [ValidateSet('All','Standard', 'Recovery', 'Planned', 'Missing', 'Replica', 'AppConsistentReplica','SyncedReplica')]
    [string]$CheckpointType = "All"
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'VMName'       = '*'
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        if ($CheckpointType -ne "All") { $params.Add('SnapshotType', $CheckpointType) }

        $checkpoints = Get-VMSnapshot @params

        $results = foreach ($cp in $checkpoints) {
            [PSCustomObject]@{
                VMName               = $cp.VMName
                CheckpointName       = $cp.Name
                CheckpointType       = $cp.SnapshotType
                CreationTime         = $cp.CreationTime
                ParentCheckpointName = $cp.ParentCheckpointName
                ComputerName         = $cp.ComputerName
                Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object VMName, CreationTime)
    }
    catch {
        throw
    }
}
