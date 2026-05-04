#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures settings for a Hyper-V host

.DESCRIPTION
    Updates various administrative settings for a Microsoft Hyper-V host, including default storage paths, NUMA spanning, and migration limits.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VirtualHardDiskPath
    Optional. Specifies the default folder to store virtual hard disks.

.PARAMETER VirtualMachinePath
    Optional. Specifies the default folder to store virtual machine configuration files.

.PARAMETER NumaSpanningEnabled
    Optional. Specifies whether virtual machines can use resources from more than one NUMA node.

.PARAMETER MaximumStorageMigrations
    Optional. Specifies the maximum number of simultaneous storage migrations.

.PARAMETER EnableEnhancedSessionMode
    Optional. Specifies whether Enhanced Session Mode is allowed.

.EXAMPLE
    PS> ./Set-HyperVHostConfig.ps1 -VirtualHardDiskPath "D:\Hyper-V\VHDs" -MaximumStorageMigrations 4

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [string]$VirtualHardDiskPath,

    [string]$VirtualMachinePath,

    [bool]$NumaSpanningEnabled,

    [int]$MaximumStorageMigrations,

    [bool]$EnableEnhancedSessionMode
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        
        if ($PSBoundParameters.ContainsKey('VirtualHardDiskPath')) { $params.Add('VirtualHardDiskPath', $VirtualHardDiskPath) }
        if ($PSBoundParameters.ContainsKey('VirtualMachinePath')) { $params.Add('VirtualMachinePath', $VirtualMachinePath) }
        if ($PSBoundParameters.ContainsKey('NumaSpanningEnabled')) { $params.Add('NumaSpanningEnabled', $NumaSpanningEnabled) }
        if ($PSBoundParameters.ContainsKey('MaximumStorageMigrations')) { $params.Add('MaximumStorageMigrations', $MaximumStorageMigrations) }
        if ($PSBoundParameters.ContainsKey('EnableEnhancedSessionMode')) { $params.Add('EnableEnhancedSessionMode', $EnableEnhancedSessionMode) }

        if ($params.Count -gt 3) {
            Set-VMHost @params
        }

        $hostInfo = Get-VMHost -ComputerName $ComputerName -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            ComputerName              = $hostInfo.Name
            VirtualHardDiskPath       = $hostInfo.VirtualHardDiskPath
            VirtualMachinePath        = $hostInfo.VirtualMachinePath
            NumaSpanningEnabled       = $hostInfo.NumaSpanningEnabled
            MaximumStorageMigrations  = $hostInfo.MaximumStorageMigrations
            Action                    = "HostConfigUpdated"
            Status                    = "Success"
            Timestamp                 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
