#Requires -Version 5.1

<#
.SYNOPSIS
    VMware: Retrieves virtual hard disks
.DESCRIPTION
    Retrieves hard disks from VMs, templates, snapshots, or datastores on a vCenter Server.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    Credentials for authenticating with the server
.PARAMETER VMName
    Virtual machine name to retrieve disks from
.PARAMETER TemplateName
    Template name to retrieve disks from
.PARAMETER SnapshotName
    Snapshot name to retrieve disks from
.PARAMETER DatastoreName
    Datastore name to search for hard disks
.PARAMETER DiskName
    Name of the hard disk to retrieve
.PARAMETER DiskID
    ID of the hard disk to retrieve
.PARAMETER DiskType
    Type filter: rawVirtual, rawPhysical, flat, unknown
.EXAMPLE
    PS> ./Get-HardDisk.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01"
.CATEGORY VMware
#>

[CmdletBinding(DefaultParameterSetName = "VM")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [Parameter(Mandatory = $true, ParameterSetName = "Datastore")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [Parameter(Mandatory = $true, ParameterSetName = "Datastore")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$SnapshotName,
    [Parameter(Mandatory = $true, ParameterSetName = "Datastore")]
    [string]$DatastoreName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [Parameter(ParameterSetName = "Datastore")]
    [string]$DiskName = '*',
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [Parameter(ParameterSetName = "Datastore")]
    [string]$DiskID,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [Parameter(ParameterSetName = "Datastore")]
    [ValidateSet("rawVirtual", "rawPhysical", "flat", "unknown")]
    [string]$DiskType
)

Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSCmdlet.ParameterSetName -eq "Snapshot") { $vm = Get-VM @cmdArgs -Name $VMName; $snap = Get-Snapshot @cmdArgs -Name $SnapshotName -VM $vm; $cmdArgs.Add('Snapshot', $snap) }
        elseif ($PSCmdlet.ParameterSetName -eq "Template") { $temp = Get-Template @cmdArgs -Name $TemplateName; $cmdArgs.Add('Template', $temp) }
        elseif ($PSCmdlet.ParameterSetName -eq "Datastore") { $store = Get-Datastore @cmdArgs -Name $DatastoreName; $cmdArgs.Add('Datastore', $store) }
        else { $vm = Get-VM @cmdArgs -Name $VMName; $cmdArgs.Add('VM', $vm) }
        if (-not [System.String]::IsNullOrWhiteSpace($DiskID)) { $cmdArgs.Add('Id', $DiskID) }
        else { $cmdArgs.Add('Name', $DiskName) }
        if (-not [System.String]::IsNullOrWhiteSpace($DiskType)) { $cmdArgs.Add('DiskType', $DiskType) }
        $result = Get-HardDisk @cmdArgs
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
