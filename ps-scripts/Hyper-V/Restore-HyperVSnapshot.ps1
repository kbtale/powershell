#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Restores a virtual machine snapshot

.DESCRIPTION
    Applies a specified Microsoft Hyper-V virtual machine snapshot (checkpoint), reverting the VM to that previous state.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VMName
    Specifies the name of the virtual machine.

.PARAMETER Name
    Specifies the name of the snapshot (checkpoint) to restore.

.EXAMPLE
    PS> ./Restore-HyperVSnapshot.ps1 -VMName "Dev-Srv" -Name "Stable-v1"

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
            throw "Snapshot '$Name' not found on VM '$VMName'."
        }

        Restore-VMSnapshot -VMSnapshot $snapshot -Confirm:$false -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName       = $VMName
            SnapshotName = $Name
            Action       = "SnapshotRestored"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
