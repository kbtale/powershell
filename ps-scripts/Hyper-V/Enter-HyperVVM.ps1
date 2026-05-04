#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Establishes a PowerShell Direct session with a virtual machine

.DESCRIPTION
    Establishes an interactive or non-interactive PowerShell session with a Microsoft Hyper-V virtual machine using PowerShell Direct (VMBus). No network connectivity to the VM is required.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection to the Hyper-V host.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER VMCredential
    Specifies the credentials to use inside the virtual machine.

.PARAMETER ScriptBlock
    Optional. A script block to execute inside the virtual machine. If not provided, an interactive session is attempted.

.EXAMPLE
    PS> ./Enter-HyperVVM.ps1 -Name "Web-Srv" -VMCredential $cred -ScriptBlock { Get-Service }

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [PSCredential]$VMCredential,

    [scriptblock]$ScriptBlock
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

        if ($ScriptBlock) {
            $result = Invoke-Command -VMName $vm.Name -Credential $VMCredential -ScriptBlock $ScriptBlock -ErrorAction Stop
            Write-Output $result
        }
        else {
            Enter-PSSession -VMName $vm.Name -Credential $VMCredential
        }
    }
    catch {
        throw
    }
}
