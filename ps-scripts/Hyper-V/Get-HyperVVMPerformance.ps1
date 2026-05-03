#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves resource metering data for a virtual machine

.DESCRIPTION
    Gets resource utilization data (CPU, Memory, Disk, Network) for a specified Microsoft Hyper-V virtual machine using resource metering.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER EnableMetering
    Optional. If set, enables resource metering on the virtual machine if it is currently disabled.

.EXAMPLE
    PS> ./Get-HyperVVMPerformance.ps1 -Name "SQL-Srv" -EnableMetering

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [switch]$EnableMetering
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

        if ($EnableMetering -and -not $vm.ResourceMeteringEnabled) {
            Enable-VMResourceMetering -VM $vm -ErrorAction Stop
            $vm = Get-VM -VM $vm # Refresh object
        }

        if (-not $vm.ResourceMeteringEnabled) {
            throw "Resource metering is not enabled for VM '$Name'. Use -EnableMetering to enable it."
        }

        $metrics = Measure-VM -VM $vm -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName                = $vm.Name
            AverageProcessorUsage = $metrics.AverageProcessorUsage
            AverageMemoryUsage    = $metrics.AverageMemoryUsage
            MaximumMemoryUsage    = $metrics.MaximumMemoryUsage
            MinimumMemoryUsage    = $metrics.MinimumMemoryUsage
            TotalDiskAllocation   = $metrics.TotalDiskAllocation
            NetworkInbound        = $metrics.NetworkInbound
            NetworkOutbound       = $metrics.NetworkOutbound
            MeteringDuration      = $metrics.MeteringDuration
            Status                = "Success"
            Timestamp             = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
