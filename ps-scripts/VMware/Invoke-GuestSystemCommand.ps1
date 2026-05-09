#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Invokes a command for the specified VM guest OS (Stop, Suspend, Restart)
.DESCRIPTION
    Executes a guest OS command on a VM identified by ID or name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER Command
    Command to execute: Stop, Suspend, or Restart
.EXAMPLE
    PS> ./Invoke-GuestSystemCommand.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -Command "Restart"
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
    [ValidateSet('Stop', 'Suspend', 'Restart')]
    [string]$Command
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('OSFullName', 'State', 'IPAddress', 'Disks', 'ConfiguredGuestId', 'ToolsVersion')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        switch ($Command) {
            "Stop"    { Stop-VMGuest -VM $machine -Server $vmServer -Confirm:$false -ErrorAction Stop }
            "Suspend" { Suspend-VMGuest -VM $machine -Server $vmServer -Confirm:$false -ErrorAction Stop }
            "Restart" { Restart-VMGuest -VM $machine -Server $vmServer -Confirm:$false -ErrorAction Stop }
        }
        $result = Get-VMGuest -VM $machine -Server $vmServer -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
