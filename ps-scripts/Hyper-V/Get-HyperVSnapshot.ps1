#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Lists snapshots associated with a virtual machine

.DESCRIPTION
    Retrieves an inventory of all snapshots (checkpoints) for a specified Microsoft Hyper-V virtual machine. Supports filtering by snapshot type.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VMName
    Specifies the name of the virtual machine.

.PARAMETER SnapshotType
    Optional. Specifies the type of snapshots to retrieve (e.g., Standard, Recovery).

.EXAMPLE
    PS> ./Get-HyperVSnapshot.ps1 -VMName "WebServer01"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [ValidateSet('Standard', 'Recovery', 'Replica', 'AppConsistentReplica')]
    [string]$SnapshotType
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'VMName'       = $VMName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        if ($SnapshotType) { $params.Add('SnapshotType', $SnapshotType) }

        $snapshots = Get-VMSnapshot @params
        
        $results = foreach ($s in $snapshots) {
            [PSCustomObject]@{
                Name         = $s.Name
                VMName       = $s.VMName
                SnapshotType = $s.SnapshotType
                CreationTime = $s.CreationTime
                ComputerName = $s.ComputerName
            }
        }

        Write-Output ($results | Sort-Object CreationTime -Descending)
    }
    catch {
        throw
    }
}
