#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Manages virtual machine resource metering

.DESCRIPTION
    Enables, disables, or resets resource metering for a specifies Microsoft Hyper-V virtual machine to track resource utilization.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Action
    Specifies the action to perform (Enable, Disable, Reset).

.EXAMPLE
    PS> ./Set-HyperVVMResourceMetering.ps1 -Name "SQL-Srv" -Action Enable

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Enable', 'Disable', 'Reset')]
    [string]$Action
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

        switch ($Action) {
            'Enable'  { Enable-VMResourceMetering -VM $vm }
            'Disable' { Disable-VMResourceMetering -VM $vm }
            'Reset'   { Reset-VMResourceMetering -VM $vm }
        }

        $result = [PSCustomObject]@{
            Name                    = $vm.Name
            Action                  = $Action
            ResourceMeteringEnabled = (Get-VM -VM $vm).ResourceMeteringEnabled
            Status                  = "Success"
            Timestamp               = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
