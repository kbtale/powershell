#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves virtual network adapters
.DESCRIPTION
    Retrieves virtual network adapters from VMs, templates, or snapshots on a vCenter Server.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine from which to retrieve network adapters
.PARAMETER TemplateName
    Virtual machine template from which to retrieve network adapters
.PARAMETER SnapshotName
    Snapshot from which to retrieve network adapters
.PARAMETER AdapterName
    Name of the network adapter to retrieve; retrieves all if empty
.EXAMPLE
    PS> ./Get-NetworkAdapter.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "VM")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$SnapshotName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$AdapterName = '*'
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSCmdlet.ParameterSetName -eq "Snapshot") { $vm = Get-VM @cmdArgs -Name $VMName; $snap = Get-Snapshot @cmdArgs -Name $SnapshotName -VM $vm; $cmdArgs.Add('Snapshot', $snap) }
        elseif ($PSCmdlet.ParameterSetName -eq "Template") { $temp = Get-Template @cmdArgs -Name $TemplateName; $cmdArgs.Add('Template', $temp) }
        else { $vm = Get-VM @cmdArgs -Name $VMName; $cmdArgs.Add('VM', $vm) }
        $result = Get-NetworkAdapter @cmdArgs -Name $AdapterName -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}