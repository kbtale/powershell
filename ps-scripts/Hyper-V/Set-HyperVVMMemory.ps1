#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures memory settings for a virtual machine

.DESCRIPTION
    Updates the memory configuration for a Microsoft Hyper-V virtual machine, including static vs. dynamic memory, startup allocation, and resource priority.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER DynamicMemory
    Optional. If set, enables dynamic memory. If not set (and was previously enabled), disables it.

.PARAMETER StartupBytes
    Optional. Specifies the amount of memory assigned on startup (e.g., 2GB, 4096MB).

.PARAMETER MinimumBytes
    Optional. Specifies the minimum amount of memory for dynamic memory.

.PARAMETER MaximumBytes
    Optional. Specifies the maximum amount of memory for dynamic memory.

.PARAMETER Buffer
    Optional. Specifies the percentage of memory to reserve as a buffer (5-2000).

.PARAMETER Priority
    Optional. Specifies the memory availability priority (0-100).

.EXAMPLE
    PS> ./Set-HyperVVMMemory.ps1 -Name "AppSrv" -StartupBytes 4GB -DynamicMemory

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [switch]$DynamicMemory,

    [uint64]$StartupBytes,

    [uint64]$MinimumBytes,

    [uint64]$MaximumBytes,

    [ValidateRange(5, 2000)]
    [int]$Buffer,

    [ValidateRange(0, 100)]
    [int]$Priority
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

        $memParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
        
        if ($PSBoundParameters.ContainsKey('DynamicMemory')) {
            $memParams.Add('DynamicMemoryEnabled', $DynamicMemory.IsPresent)
        }

        if ($StartupBytes) { $memParams.Add('StartupBytes', $StartupBytes) }
        if ($MinimumBytes) { $memParams.Add('MinimumBytes', $MinimumBytes) }
        if ($MaximumBytes) { $memParams.Add('MaximumBytes', $MaximumBytes) }
        if ($Buffer) { $memParams.Add('Buffer', $Buffer) }
        if ($Priority) { $memParams.Add('Priority', $Priority) }

        if ($memParams.Count -gt 2) {
            Set-VMMemory @memParams
        }

        $updatedMem = Get-VMMemory -VM $vm
        
        $result = [PSCustomObject]@{
            VMName               = $vm.Name
            DynamicMemoryEnabled = $updatedMem.DynamicMemoryEnabled
            StartupBytes         = $updatedMem.StartupBytes
            MinimumBytes         = $updatedMem.MinimumBytes
            MaximumBytes         = $updatedMem.MaximumBytes
            Buffer               = $updatedMem.Buffer
            Priority             = $updatedMem.Priority
            Action               = "MemoryConfigUpdated"
            Status               = "Success"
            Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
