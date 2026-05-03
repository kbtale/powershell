#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures virtual processor settings for a virtual machine

.DESCRIPTION
    Updates the number of virtual processors and resource controls (reserve, limit, weight) for a Microsoft Hyper-V virtual machine.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER ProcessorCount
    Optional. Specifies the number of virtual processors.

.PARAMETER Reserve
    Optional. Specifies the percentage of host CPU resources to reserve for the VM.

.PARAMETER Limit
    Optional. Specifies the maximum percentage of host CPU resources the VM can use.

.PARAMETER RelativeWeight
    Optional. Specifies the priority of the VM relative to others when competing for CPU resources (1-10000).

.EXAMPLE
    PS> ./Set-HyperVVMProcessor.ps1 -Name "AppSrv" -ProcessorCount 4 -Limit 80

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [int]$ProcessorCount,

    [ValidateRange(0, 100)]
    [int]$Reserve,

    [ValidateRange(0, 100)]
    [int]$Limit,

    [ValidateRange(1, 10000)]
    [int]$RelativeWeight
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
        if ($PSBoundParameters.ContainsKey('ProcessorCount')) { $setParams.Add('ProcessorCount', $ProcessorCount) }
        if ($PSBoundParameters.ContainsKey('Reserve')) { $setParams.Add('Reserve', $Reserve) }
        if ($PSBoundParameters.ContainsKey('Limit')) { $setParams.Add('Limit', $Limit) }
        if ($PSBoundParameters.ContainsKey('RelativeWeight')) { $setParams.Add('RelativeWeight', $RelativeWeight) }

        if ($setParams.Count -gt 2) {
            Set-VM @setParams
        }

        $result = [PSCustomObject]@{
            VMName         = $vm.Name
            ProcessorCount = (Get-VM -VM $vm).ProcessorCount
            Reserve        = (Get-VMProcessor -VM $vm).Reserve
            Limit          = (Get-VMProcessor -VM $vm).Limit
            RelativeWeight = (Get-VMProcessor -VM $vm).RelativeWeight
            Action         = "ProcessorConfigUpdated"
            Status         = "Success"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
