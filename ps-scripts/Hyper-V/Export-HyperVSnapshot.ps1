#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Exports a virtual machine snapshot to disk

.DESCRIPTION
    Retrieves a specific virtual machine snapshot (checkpoint) and exports it to a specified directory on the host.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VMName
    Specifies the name of the virtual machine.

.PARAMETER SnapshotName
    Specifies the name of the snapshot (checkpoint) to export.

.PARAMETER Path
    Specifies the destination directory for the exported snapshot.

.EXAMPLE
    PS> ./Export-HyperVSnapshot.ps1 -VMName "DB-Srv" -SnapshotName "Pre-Patch" -Path "E:\Exports"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$SnapshotName,

    [Parameter(Mandatory = $true)]
    [string]$Path
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'VMName'       = $VMName
            'Name'         = $SnapshotName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $snapshot = Get-VMSnapshot @params

        if (-not $snapshot) {
            throw "Snapshot '$SnapshotName' not found on VM '$VMName'."
        }

        Export-VMSnapshot -VMSnapshot $snapshot -Path $Path -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName       = $VMName
            SnapshotName = $SnapshotName
            ExportPath   = $Path
            Action       = "SnapshotExported"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
