#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
    VMware: Creates a new virtual floppy drive
.DESCRIPTION
    Connects to a vCenter Server and creates a new virtual floppy drive attached to a VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine to which to attach the new floppy drive
.PARAMETER FloppyImagePath
    Datastore path to the floppy image file backing the virtual floppy drive
.PARAMETER HostDevice
    Path to the floppy drive on the host backing the virtual floppy drive
.PARAMETER NewFloppyImagePath
    New datastore path to a floppy image file backing the virtual floppy drive
.PARAMETER StartConnected
    Floppy drive starts connected when the VM powers on
.EXAMPLE
    PS> ./New-FloppyDrive.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01"
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
    [string]$NewFloppyImagePath,
    [switch]$StartConnected
)

Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        if ([System.String]::IsNullOrWhiteSpace($NewFloppyImagePath)) {
            $floppy = New-FloppyDrive -Server $vmServer -VM $machine -StartConnected:$StartConnected -Confirm:$false -ErrorAction Stop
        }
        else {
            $floppy = New-FloppyDrive -Server $vmServer -VM $machine -NewFloppyImagePath $NewFloppyImagePath -StartConnected:$StartConnected -Confirm:$false -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('FloppyImagePath')) { $null = Set-FloppyDrive -Floppy $floppy -FloppyImagePath $FloppyImagePath -Confirm:$false -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('HostDevice')) { $null = Set-FloppyDrive -Floppy $floppy -HostDevice $HostDevice -Confirm:$false -ErrorAction Stop }
        $result = Get-FloppyDrive -Server $vmServer -VM $machine -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
