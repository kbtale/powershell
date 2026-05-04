#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures virtual machine checkpoint policies and storage

.DESCRIPTION
    Updates the checkpoint (snapshot) configuration for a Microsoft Hyper-V virtual machine, including the checkpoint type (Production vs Standard) and the file storage location.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER CheckpointType
    Optional. Specifies the type of checkpoints to create (Disabled, Standard, Production, ProductionOnly).

.PARAMETER Path
    Optional. Specifies the folder path where checkpoint files will be stored.

.EXAMPLE
    PS> ./Set-HyperVVMCheckpointConfig.ps1 -Name "WebSrv" -CheckpointType Production -Path "D:\Hyper-V\Checkpoints"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet('Disabled', 'Standard', 'Production', 'ProductionOnly')]
    [string]$CheckpointType,

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

        $setParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
        if ($CheckpointType) { $setParams.Add('CheckpointType', $CheckpointType) }
        if ($Path) { 
            if (-not (Test-Path -Path $Path)) {
                New-Item -ItemType Directory -Path $Path -Force | Out-Null
            }
            $setParams.Add('CheckpointFileLocation', $Path) 
        }

        if ($setParams.Count -gt 2) {
            Set-VM @setParams
        }

        $updatedVM = Get-VM -VM $vm
        
        $result = [PSCustomObject]@{
            VMName                 = $updatedVM.Name
            CheckpointType         = $updatedVM.CheckpointType
            CheckpointFileLocation = $updatedVM.CheckpointFileLocation
            Action                 = "CheckpointConfigUpdated"
            Status                 = "Success"
            Timestamp              = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
