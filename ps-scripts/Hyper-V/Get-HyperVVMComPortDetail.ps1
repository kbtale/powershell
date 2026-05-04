#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits virtual machine COM port configurations

.DESCRIPTION
    Retrieves detailed information for virtual serial ports (COM ports) on a Microsoft Hyper-V virtual machine, including named pipe associations or hardware path bindings.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Get-HyperVVMComPortDetail.ps1 -Name "Linux-App"

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

        $comPorts = Get-VMComPort -VM $vm -ErrorAction Stop
        
        $results = foreach ($port in $comPorts) {
            [PSCustomObject]@{
                VMName     = $vm.Name
                PortName   = $port.Name
                Path       = $port.Path
                IsAttached = [bool]$port.Path
                Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
