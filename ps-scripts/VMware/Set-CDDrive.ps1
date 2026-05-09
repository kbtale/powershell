#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the configuration of a virtual CD drive
.DESCRIPTION
    Modifies settings of a specified virtual CD drive.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine whose CD drive to modify
.PARAMETER TemplateName
    Virtual machine template whose CD drive to modify
.PARAMETER SnapshotName
    Snapshot whose CD drive to modify
.PARAMETER DriveName
    Name of the CD drive to modify
.PARAMETER Connected
    Connect or disconnect the CD drive
.PARAMETER NoMedia
    Detach any connected media from the CD drive
.PARAMETER HostDevice
    Host CD drive backing the virtual CD drive
.PARAMETER IsoPath
    Datastore path to the ISO file backing the virtual CD drive
.PARAMETER StartConnected
    CD drive starts connected when the VM powers on
.EXAMPLE
    PS> ./Set-CDDrive.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01" -IsoPath "[datastore1] ISOs/win.iso"
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
    [string]$DriveName = '*',
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$Connected,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [switch]$NoMedia,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$HostDevice,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$IsoPath,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$StartConnected
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSCmdlet.ParameterSetName -eq "Snapshot") { $vm = Get-VM @cmdArgs -Name $VMName; $snap = Get-Snapshot @cmdArgs -Name $SnapshotName -VM $vm; $cmdArgs.Add('Snapshot', $snap) }
        elseif ($PSCmdlet.ParameterSetName -eq "Template") { $temp = Get-Template @cmdArgs -Name $TemplateName; $cmdArgs.Add('Template', $temp) }
        else { $vm = Get-VM @cmdArgs -Name $VMName; $cmdArgs.Add('VM', $vm) }
        $drive = Get-CDDrive @cmdArgs -Name $DriveName -ErrorAction Stop
        if ($null -eq $drive) { throw "No CD drive found" }
        $setArgs = @{ ErrorAction = 'Stop'; CD = $drive; Server = $vmServer; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('IsoPath')) { $null = Set-CDDrive @setArgs -IsoPath $IsoPath }
        if ($PSBoundParameters.ContainsKey('HostDevice')) { $null = Set-CDDrive @setArgs -HostDevice $HostDevice }
        if ($PSBoundParameters.ContainsKey('Connected')) { $null = Set-CDDrive @setArgs -Connected $Connected }
        if ($PSBoundParameters.ContainsKey('NoMedia')) { $null = Set-CDDrive @setArgs -NoMedia:$NoMedia }
        if ($PSBoundParameters.ContainsKey('StartConnected')) { $null = Set-CDDrive @setArgs -StartConnected $StartConnected }
        $result = Get-CDDrive @cmdArgs -Name $drive.Name -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}