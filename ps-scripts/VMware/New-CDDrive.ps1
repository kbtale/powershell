#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
    VMware: Creates a new virtual CD drive
.DESCRIPTION
    Connects to a vCenter Server and creates a new virtual CD drive attached to a VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine to which to attach the new CD drive
.PARAMETER HostDevice
    Path to the CD drive on the host backing the virtual CD drive
.PARAMETER IsoPath
    Datastore path to the ISO file backing the virtual CD drive
.PARAMETER StartConnected
    CD drive starts connected when the VM powers on
.EXAMPLE
    PS> ./New-CDDrive.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01" -IsoPath "[datastore1] ISOs/win.iso"
.CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [string]$HostDevice,
    [string]$IsoPath,
    [switch]$StartConnected
)

Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        $drive = New-CDDrive -Server $vmServer -VM $machine -StartConnected:$StartConnected -Confirm:$false -ErrorAction Stop
        if ($PSBoundParameters.ContainsKey('IsoPath')) { $null = Set-CDDrive -CD $drive -IsoPath $IsoPath -Confirm:$false -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('HostDevice')) { $null = Set-CDDrive -CD $drive -HostDevice $HostDevice -Confirm:$false -ErrorAction Stop }
        $result = Get-CDDrive -Server $vmServer -VM $machine -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
