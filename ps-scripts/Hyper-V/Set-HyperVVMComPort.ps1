#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures COM port settings for a virtual machine

.DESCRIPTION
    Updates the serial port (COM port) configuration for a Microsoft Hyper-V virtual machine, including named pipe paths and debugger mode.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Number
    Specifies the COM port number (1 or 2).

.PARAMETER Path
    Optional. Specifies the path to a named pipe (e.g., \\.\pipe\TestPipe). If empty, the port is disconnected.

.PARAMETER DebuggerMode
    Optional. Specifies whether the COM port is enabled for use by debuggers ($true) or disabled ($false).

.EXAMPLE
    PS> ./Set-HyperVVMComPort.ps1 -Name "Debug-Srv" -Number 1 -Path "\\.\pipe\SrvDebug"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet(1, 2)]
    [int]$Number,

    [string]$Path,

    [bool]$DebuggerMode
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

        $comParams = @{ 'VM' = $vm; 'Number' = $Number; 'ErrorAction' = 'Stop' }
        if ($Path) { $comParams.Add('Path', $Path) }
        else { $comParams.Add('Path', $null) } # Disconnect

        if ($PSBoundParameters.ContainsKey('DebuggerMode')) {
            $comParams.Add('DebuggerMode', [string]$DebuggerMode)
        }

        Set-VMComPort @comParams

        $result = [PSCustomObject]@{
            VMName       = $vm.Name
            ComPort      = $Number
            Path         = (Get-VMComPort -VM $vm -Number $Number).Path
            DebuggerMode = (Get-VMComPort -VM $vm -Number $Number).DebuggerMode
            Action       = "ComPortConfigUpdated"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
