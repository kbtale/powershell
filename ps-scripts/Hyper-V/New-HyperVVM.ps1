#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Provisions a new virtual machine

.DESCRIPTION
    Creates a new Microsoft Hyper-V virtual machine with specified resources, storage, and networking.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name of the new virtual machine.

.PARAMETER Generation
    Specifies the generation (1 or 2). Defaults to 2.

.PARAMETER StartupMemory
    Specifies the amount of memory assigned to the VM (e.g., 2GB, 4096MB). Defaults to 1GB.

.PARAMETER ProcessorCount
    Specifies the number of virtual processors. Defaults to 1.

.PARAMETER Path
    Optional. Specifies the directory to store VM configuration files. Defaults to the host default.

.PARAMETER SwitchName
    Optional. Specifies the name of the virtual switch to connect to.

.PARAMETER VHDPath
    Optional. Specifies the path to an existing virtual hard disk to attach.

.PARAMETER NewVHDSizeBytes
    Optional. Creates a new dynamic VHDX with the specified size (e.g., 40GB).

.PARAMETER NewVHDPath
    Optional. Specifies the path for the new VHDX. Required if NewVHDSizeBytes is specified.

.EXAMPLE
    PS> ./New-HyperVVM.ps1 -Name "WebServer-01" -StartupMemory 4GB -ProcessorCount 2 -SwitchName "External"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet(1, 2)]
    [int]$Generation = 2,

    [uint64]$StartupMemory = 1GB,

    [int]$ProcessorCount = 1,

    [string]$Path,

    [string]$SwitchName,

    [string]$VHDPath,

    [uint64]$NewVHDSizeBytes,

    [string]$NewVHDPath
)

Process {
    try {
        $params = @{
            'Name'               = $Name
            'Generation'         = $Generation
            'MemoryStartupBytes' = $StartupMemory
            'ComputerName'       = $ComputerName
            'ErrorAction'        = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        if ($Path) { $params.Add('Path', $Path) }

        if ($VHDPath) {
            $params.Add('VHDPath', $VHDPath)
        }
        elseif ($NewVHDSizeBytes -gt 0) {
            if (-not $NewVHDPath) {
                throw "NewVHDPath is required when NewVHDSizeBytes is specified."
            }
            $params.Add('NewVHDSizeBytes', $NewVHDSizeBytes)
            $params.Add('NewVHDPath', $NewVHDPath)
        }
        else {
            $params.Add('NoVHD', $true)
        }

        $vm = New-VM @params

        if ($ProcessorCount -gt 1) {
            Set-VM -VM $vm -ProcessorCount $ProcessorCount -ErrorAction Stop
        }

        if ($SwitchName) {
            Connect-VMNetworkAdapter -VM $vm -SwitchName $SwitchName -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            Name           = $vm.Name
            Id             = $vm.Id
            Generation     = $vm.Generation
            MemoryAssigned = $vm.MemoryAssigned
            ProcessorCount = $ProcessorCount
            Action         = "VirtualMachineCreated"
            Status         = "Success"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
