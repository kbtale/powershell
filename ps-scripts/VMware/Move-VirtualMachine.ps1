#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Move the virtual machine to another location
.DESCRIPTION
    Moves a VM to another datastore, folder, datacenter, host, or resource pool.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER DatastoreName
    Datastore where to move the VM
.PARAMETER FolderName
    Folder where to move the VM
.PARAMETER DatacenterName
    Datacenter where to move the VM
.PARAMETER HostName
    Host where to move the VM
.PARAMETER ResourcePoolName
    Resource pool where to move the VM
.PARAMETER DiskStorageFormat
    New storage format for the hard disk
.EXAMPLE
    PS> ./Move-VirtualMachine.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -DatastoreName "ds2"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "toDatastore")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "toDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "toDatacenter")]
    [Parameter(Mandatory = $true, ParameterSetName = "toFolder")]
    [Parameter(Mandatory = $true, ParameterSetName = "toHost")]
    [Parameter(Mandatory = $true, ParameterSetName = "toResourcePool")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "toDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "toDatacenter")]
    [Parameter(Mandatory = $true, ParameterSetName = "toFolder")]
    [Parameter(Mandatory = $true, ParameterSetName = "toHost")]
    [Parameter(Mandatory = $true, ParameterSetName = "toResourcePool")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "toDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "toDatacenter")]
    [Parameter(Mandatory = $true, ParameterSetName = "toFolder")]
    [Parameter(Mandatory = $true, ParameterSetName = "toHost")]
    [Parameter(Mandatory = $true, ParameterSetName = "toResourcePool")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "toDatastore")]
    [string]$DatastoreName,
    [Parameter(Mandatory = $true, ParameterSetName = "toDatacenter")]
    [string]$DatacenterName,
    [Parameter(Mandatory = $true, ParameterSetName = "toFolder")]
    [string]$FolderName,
    [Parameter(Mandatory = $true, ParameterSetName = "toHost")]
    [string]$HostName,
    [Parameter(Mandatory = $true, ParameterSetName = "toResourcePool")]
    [string]$ResourcePoolName,
    [Parameter(ParameterSetName = "toDatastore")]
    [ValidateSet("Thin", "Thick", "EagerZeroedThick")]
    [string]$DiskStorageFormat = "Thick"
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Id', 'PowerState', 'NumCpu', 'Notes', 'Guest', 'GuestId', 'MemoryMB', 'UsedSpaceGB', 'ProvisionedSpaceGB', 'Folder')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; VM = $machine; Confirm = $false }
        if ($PSCmdlet.ParameterSetName -eq "toFolder") {
            $folder = Get-Folder -Server $vmServer -Name $FolderName -Type VM -ErrorAction Stop
            $cmdArgs.Add('InventoryLocation', $folder)
        }
        if ($PSCmdlet.ParameterSetName -eq "toDatacenter") {
            $center = Get-Datacenter -Server $vmServer -Name $DatacenterName -ErrorAction Stop
            $cmdArgs.Add('InventoryLocation', $center)
        }
        if ($PSCmdlet.ParameterSetName -eq "toHost") {
            $destination = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
            $cmdArgs.Add('Destination', $destination)
        }
        if ($PSCmdlet.ParameterSetName -eq "toResourcePool") {
            $destination = Get-ResourcePool -Server $vmServer -Name $ResourcePoolName -ErrorAction Stop
            $cmdArgs.Add('Destination', $destination)
        }
        if ($PSCmdlet.ParameterSetName -eq "toDatastore") {
            $store = Get-Datastore -Server $vmServer -Name $DatastoreName -ErrorAction Stop
            $cmdArgs.Add('Datastore', $store)
            $cmdArgs.Add('DiskStorageFormat', $DiskStorageFormat)
        }
        $result = Move-VM @cmdArgs | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
