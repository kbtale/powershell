#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Invokes a command for the specified virtual machine (Start, Stop, Suspend, Restart)
.DESCRIPTION
    Executes a power command on a VM identified by ID or name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER Command
    Command to execute: Start, Stop, Suspend, or Restart
.PARAMETER Kill
    Stop the VM by terminating ESX processes
.EXAMPLE
    PS> ./Invoke-VirtualMachineCommand.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -Command "Restart"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [ValidateSet('Start', 'Stop', 'Suspend', 'Restart')]
    [string]$Command = 'Restart',
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$Kill
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        switch ($Command) {
            "Start"   { $null = Start-VM -VM $machine -Server $vmServer -Confirm:$false -ErrorAction Stop }
            "Stop"    { $null = Stop-VM -VM $machine -Server $vmServer -Kill:$Kill -Confirm:$false -ErrorAction Stop }
            "Suspend" { $null = Suspend-VM -VM $machine -Server $vmServer -Confirm:$false -ErrorAction Stop }
            "Restart" { $null = Restart-VM -VM $machine -Server $vmServer -Confirm:$false -ErrorAction Stop }
        }
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Command $Command successfully executed on VM $($machine.Name)"
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
