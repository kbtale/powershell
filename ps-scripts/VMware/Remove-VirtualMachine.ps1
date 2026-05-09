#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes a virtual machine from the vCenter Server system
.DESCRIPTION
    Removes a VM by ID or name, optionally deleting from the datastore.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the VM to remove
.PARAMETER VMName
    Name of the VM to remove
.PARAMETER DeletePermanently
    Delete from the datastore as well as inventory
.EXAMPLE
    PS> ./Remove-VirtualMachine.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "OldVM"
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
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$DeletePermanently
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") { $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop }
        else { $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop }
        $null = Remove-VM -Server $vmServer -VM $machine -DeletePermanently:$DeletePermanently -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Virtual machine $($machine.Name) successfully removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}