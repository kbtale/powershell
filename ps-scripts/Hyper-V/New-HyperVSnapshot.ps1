#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Creates a new virtual machine snapshot

.DESCRIPTION
    Creates a new snapshot (checkpoint) of a specified Microsoft Hyper-V virtual machine.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VMName
    Specifies the name of the virtual machine.

.PARAMETER Name
    Optional. Specifies a custom name for the snapshot. If omitted, Hyper-V generates a default name.

.EXAMPLE
    PS> ./New-HyperVSnapshot.ps1 -VMName "AppSrv01" -Name "BeforeMigration"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [string]$Name
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'VMName'       = $VMName
            'Passthru'     = $true
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        if ($Name) { $params.Add('SnapshotName', $Name) }

        $snapshot = Checkpoint-VM @params

        $result = [PSCustomObject]@{
            VMName       = $VMName
            SnapshotName = $snapshot.Name
            CreationTime = $snapshot.CreationTime
            Action       = "SnapshotCreated"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
