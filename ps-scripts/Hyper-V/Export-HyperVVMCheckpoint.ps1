#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Exports a virtual machine checkpoint to a specified path

.DESCRIPTION
    Exports a specifies Microsoft Hyper-V virtual machine checkpoint (snapshot), including its configuration and associated virtual hard disk state, to a specifies directory.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER CheckpointName
    Specifies the name of the checkpoint to export.

.PARAMETER Path
    Specifies the directory path where the checkpoint will be exported.

.EXAMPLE
    PS> ./Export-HyperVVMCheckpoint.ps1 -Name "AppSrv" -CheckpointName "Before-Update-v2" -Path "E:\Backups\Checkpoints"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$CheckpointName,

    [Parameter(Mandatory = $true)]
    [string]$Path
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

        $checkpoint = Get-VMSnapshot -VM $vm -Name $CheckpointName -ErrorAction Stop

        if (-not $checkpoint) {
            throw "Checkpoint '$CheckpointName' not found for VM '$Name'."
        }

        if (-not (Test-Path -Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }

        Export-VMSnapshot -VMSnapshot $checkpoint -Path $Path -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName         = $vm.Name
            CheckpointName = $checkpoint.Name
            ExportPath     = $Path
            Action         = "CheckpointExported"
            Status         = "Success"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
