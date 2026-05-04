#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits virtual machine resource metering and usage statistics

.DESCRIPTION
    Retrieves detailed resource utilization data for a specifies Microsoft Hyper-V virtual machine using resource metering. Requires resource metering to be enabled.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Measure-HyperVVM.ps1 -Name "App-Node-01"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name
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

        if ($vm.ResourceMeteringEnabled -ne $true) {
            Write-Warning "Resource metering is not enabled for VM '$Name'. Enabling metering to retrieve statistics..."
            Enable-VMResourceMetering -VM $vm -ErrorAction Stop
        }

        $measurement = Measure-VM -VM $vm -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            VMName                = $vm.Name
            AverageProcessorUsage = $measurement.AverageProcessorUsage
            AverageMemoryUsageMB  = [math]::Round($measurement.AverageMemoryUsage / 1MB, 2)
            MaximumMemoryUsageMB  = [math]::Round($measurement.MaximumMemoryUsage / 1MB, 2)
            MinimumMemoryUsageMB  = [math]::Round($measurement.MinimumMemoryUsage / 1MB, 2)
            TotalDiskAllocationGB = [math]::Round($measurement.TotalDiskAllocation / 1GB, 2)
            NetworkInboundMB      = [math]::Round($measurement.NetworkInbound / 1MB, 2)
            NetworkOutboundMB     = [math]::Round($measurement.NetworkOutbound / 1MB, 2)
            MeteringDuration      = $measurement.MeteringDuration
            Timestamp             = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
