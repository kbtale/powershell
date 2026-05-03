#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Renames a virtual machine snapshot

.DESCRIPTION
    Updates the name of a specifies Microsoft Hyper-V virtual machine snapshot (checkpoint).

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VMName
    Specifies the name of the virtual machine.

.PARAMETER Name
    Specifies the current name of the snapshot (checkpoint).

.PARAMETER NewName
    Specifies the new name for the snapshot.

.EXAMPLE
    PS> ./Rename-HyperVSnapshot.ps1 -VMName "AppSrv" -Name "Auto-Snapshot" -NewName "Gold-Image-V1"

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

    [Parameter(Mandatory = $true)]
    [string]$NewName
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

        $renamed = Rename-VMSnapshot -VMSnapshot $snapshot -NewName $NewName -Passthru -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName      = $VMName
            OldName     = $Name
            NewName     = $renamed.Name
            Action      = "SnapshotRenamed"
            Status      = "Success"
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
