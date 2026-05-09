#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the configuration of a virtual floppy drive
.DESCRIPTION
    Modifies settings of a specified virtual floppy drive on a VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine whose floppy drive to modify
.PARAMETER FloppyImagePath
    Datastore path to the floppy image file
.PARAMETER HostDevice
    Path to the floppy drive on the host
.PARAMETER Connected
    Connect or disconnect the floppy drive
.PARAMETER NoMedia
    Remove media from the floppy drive
.PARAMETER StartConnected
    Start connected when VM powers on
.EXAMPLE
    PS> ./Set-FloppyDrive.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01" -Connected $true
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
    [string]$FloppyImagePath,
    [string]$HostDevice,
    [bool]$Connected,
    [switch]$NoMedia,
    [bool]$StartConnected
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        $floppy = Get-FloppyDrive -Server $vmServer -VM $machine -ErrorAction Stop
        $setArgs = @{ ErrorAction = 'Stop'; Floppy = $floppy; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('FloppyImagePath')) { $null = Set-FloppyDrive @setArgs -FloppyImagePath $FloppyImagePath }
        if ($PSBoundParameters.ContainsKey('HostDevice')) { $null = Set-FloppyDrive @setArgs -HostDevice $HostDevice }
        if ($PSBoundParameters.ContainsKey('StartConnected')) { $null = Set-FloppyDrive @setArgs -StartConnected $StartConnected }
        if ($PSBoundParameters.ContainsKey('Connected')) { $null = Set-FloppyDrive @setArgs -Connected $Connected }
        if ($PSBoundParameters.ContainsKey('NoMedia')) { $null = Set-FloppyDrive @setArgs -NoMedia:$NoMedia }
        $result = Get-FloppyDrive -Server $vmServer -VM $machine -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}