#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Updates Hyper-V host configuration and resource policies

.DESCRIPTION
    Updates various Microsoft Hyper-V host-level properties, including default storage paths, NUMA spanning, storage migration limits, and session mode policies.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VirtualHardDiskPath
    Optional. Specifies the default folder for virtual hard disk files.

.PARAMETER VirtualMachinePath
    Optional. Specifies the default folder for virtual machine configuration files.

.PARAMETER NumaSpanningEnabled
    Optional. Enables or disables NUMA spanning.

.PARAMETER MaximumStorageMigrations
    Optional. Specifies the maximum number of simultaneous storage migrations.

.PARAMETER EnhancedSessionModeEnabled
    Optional. Enables or disables enhanced session mode.

.EXAMPLE
    PS> ./Set-HyperVHostInfo.ps1 -VirtualHardDiskPath "E:\Hyper-V\VHDs" -NumaSpanningEnabled $true

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [string]$VirtualHardDiskPath,

    [string]$VirtualMachinePath,

    [Nullable[bool]]$NumaSpanningEnabled,

    [int]$MaximumStorageMigrations,

    [Nullable[bool]]$EnhancedSessionModeEnabled
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $setParams = @{ 'ErrorAction' = 'Stop' }
        if ($Credential) { $setParams.Add('Credential', $Credential) }
        else { $setParams.Add('ComputerName', $ComputerName) }

        if ($VirtualHardDiskPath) { $setParams.Add('VirtualHardDiskPath', $VirtualHardDiskPath) }
        if ($VirtualMachinePath) { $setParams.Add('VirtualMachinePath', $VirtualMachinePath) }
        if ($NumaSpanningEnabled -ne $null) { $setParams.Add('NumaSpanningEnabled', [bool]$NumaSpanningEnabled) }
        if ($MaximumStorageMigrations) { $setParams.Add('MaximumStorageMigrations', $MaximumStorageMigrations) }
        if ($EnhancedSessionModeEnabled -ne $null) { $setParams.Add('EnhancedSessionModeEnabled', [bool]$EnhancedSessionModeEnabled) }

        if ($setParams.Count -gt 2) {
            Set-VMHost @setParams
        }

        $updatedHost = Get-VMHost -ComputerName $ComputerName
        
        $result = [PSCustomObject]@{
            ComputerName              = $updatedHost.ComputerName
            VirtualHardDiskPath       = $updatedHost.VirtualHardDiskPath
            VirtualMachinePath        = $updatedHost.VirtualMachinePath
            NumaSpanningEnabled       = $updatedHost.NumaSpanningEnabled
            MaximumStorageMigrations  = $updatedHost.MaximumStorageMigrations
            EnhancedSessionModeEnabled = $updatedHost.EnhancedSessionModeEnabled
            Action                    = "HostPropertiesUpdated"
            Status                    = "Success"
            Timestamp                 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
