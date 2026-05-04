#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Deletes a virtual machine snapshot

.DESCRIPTION
    Removes a specified snapshot (checkpoint) from a Microsoft Hyper-V virtual machine. Supports removing all child snapshots recursively.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VMName
    Specifies the name of the virtual machine.

.PARAMETER Name
    Specifies the name of the snapshot (checkpoint) to delete.

.PARAMETER IncludeChildren
    If set, removes the specified snapshot and all its descendant snapshots.

.EXAMPLE
    PS> ./Remove-HyperVSnapshot.ps1 -VMName "AppSrv" -Name "OldBackup" -IncludeChildren

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [switch]$IncludeChildren
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
            throw "Snapshot '$Name' not found on VM '$VMName'."
        }

        Remove-VMSnapshot -VMSnapshot $snapshot -IncludeAllChildSnapshots:$IncludeChildren -Confirm:$false -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName       = $VMName
            SnapshotName = $Name
            Action       = "SnapshotRemoved"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
