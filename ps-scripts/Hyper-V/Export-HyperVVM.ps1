#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Exports a virtual machine to a specified path

.DESCRIPTION
    Exports a Microsoft Hyper-V virtual machine, including its configuration, virtual hard disks, and any checkpoints, to a specifies directory for backup or migration purposes.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine to export.

.PARAMETER Path
    Specifies the directory path where the virtual machine will be exported.

.PARAMETER CaptureLiveState
    Optional. Specifies how to handle the virtual machine's live state (CaptureCrashConsistentState, CaptureSavedState, CaptureDataConsistentState).

.EXAMPLE
    PS> ./Export-HyperVVM.ps1 -Name "SQL-Prod" -Path "E:\Backups\Hyper-V"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$Path,

    [ValidateSet('CaptureCrashConsistentState', 'CaptureSavedState', 'CaptureDataConsistentState')]
    [string]$CaptureLiveState = "CaptureCrashConsistentState"
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

        if (-not (Test-Path -Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }

        Export-VM -VM $vm -Path $Path -CaptureLiveState $CaptureLiveState -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName           = $vm.Name
            ExportPath       = $Path
            CaptureLiveState = $CaptureLiveState
            Action           = "VMExported"
            Status           = "Success"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
