#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Connects or disconnects virtual machine network adapters to a switch

.DESCRIPTION
    Manages the virtual switch connectivity for a specifies Microsoft Hyper-V virtual machine. Can connect all adapters to a specific switch or disconnect them.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER SwitchName
    Optional. Specifies the name of the virtual switch to connect to. If not provided, adapters will be disconnected.

.PARAMETER Disconnect
    Optional. If set, disconnects all network adapters from any virtual switch.

.EXAMPLE
    PS> ./Set-HyperVVMNetworkSwitch.ps1 -Name "WebSrv" -SwitchName "External-Switch"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$SwitchName,

    [switch]$Disconnect
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

        $adapters = Get-VMNetworkAdapter -VM $vm -ErrorAction Stop

        if ($Disconnect) {
            $adapters | Disconnect-VMNetworkAdapter -ErrorAction Stop
        }
        elseif ($SwitchName) {
            $adapters | Connect-VMNetworkAdapter -SwitchName $SwitchName -ErrorAction Stop
        }

        $results = Get-VMNetworkAdapter -VM $vm | Select-Object Name, SwitchName, MacAddress, Status

        $result = [PSCustomObject]@{
            VMName    = $vm.Name
            Adapters  = $results
            Action    = if ($Disconnect) { "NetworkDisconnected" } else { "NetworkSwitchUpdated" }
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
