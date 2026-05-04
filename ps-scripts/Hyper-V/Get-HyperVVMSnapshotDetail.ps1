#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits virtual machine checkpoints/snapshots

.DESCRIPTION
    Retrieves detailed information about all checkpoints (snapshots) associated with a Microsoft Hyper-V virtual machine, including hierarchy, creation time, and storage footprint.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER SnapshotType
    Optional. Filters by checkpoint type (e.g., Standard, Recovery, Replica). Defaults to All.

.EXAMPLE
    PS> ./Get-HyperVVMSnapshotDetail.ps1 -Name "SQL-Prod" -SnapshotType Standard

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet('All', 'Standard', 'Recovery', 'Planned', 'Missing', 'Replica', 'AppConsistentReplica', 'SyncedReplica')]
    [string]$SnapshotType = "All"
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

        $snapshotParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
        if ($SnapshotType -ne 'All') {
            $snapshotParams.Add('SnapshotType', $SnapshotType)
        }

        $results = Get-VMSnapshot @snapshotParams | ForEach-Object {
            [PSCustomObject]@{
                VMName               = $vm.Name
                CheckpointName       = $_.Name
                CheckpointId         = $_.Id
                Type                 = $_.SnapshotType
                CreationTime         = $_.CreationTime
                ParentCheckpointName = $_.ParentCheckpointName
                Path                 = $_.Path
            }
        }

        Write-Output ($results | Sort-Object CreationTime -Descending)
    }
    catch {
        throw
    }
}
