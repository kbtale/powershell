#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves properties of a specific virtual machine snapshot

.DESCRIPTION
    Gets detailed configuration and status properties for a specified Microsoft Hyper-V virtual machine snapshot (checkpoint).

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VMName
    Specifies the name of the virtual machine.

.PARAMETER Name
    Specifies the name of the snapshot (checkpoint) to retrieve.

.EXAMPLE
    PS> ./Get-HyperVSnapshotInfo.ps1 -VMName "SRV01" -Name "Pre-Update"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$Name
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'VMName'       = $VMName
            'Name'         = $Name
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $snapshot = Get-VMSnapshot @params

        if (-not $snapshot) {
            throw "Snapshot '$Name' not found on VM '$VMName' on host '$ComputerName'."
        }

        $results = foreach ($s in $snapshot) {
            [PSCustomObject]@{
                Name                 = $s.Name
                Id                   = $s.Id
                VMName               = $s.VMName
                SnapshotType         = $s.SnapshotType
                CreationTime         = $s.CreationTime
                ParentCheckpointId   = $s.ParentCheckpointId
                ParentCheckpointName = $s.ParentCheckpointName
                Path                 = $s.Path
                ComputerName         = $s.ComputerName
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
