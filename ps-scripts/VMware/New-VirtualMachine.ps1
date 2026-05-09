#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new virtual machine
.DESCRIPTION
    Creates a new VM with specified CPU, memory, disk, and networking settings.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host on which to create the VM
.PARAMETER VMName
    Name for the new virtual machine
.PARAMETER Notes
    Description of the VM
.PARAMETER Cpus
    Number of virtual CPUs
.PARAMETER CoresPerSocket
    Number of cores per CPU socket
.PARAMETER MemoryGB
    Memory size in GB
.PARAMETER DiskGB
    Disk size in GB
.PARAMETER DiskStorageFormat
    Disk format: Thin, Thick, EagerZeroedThick
.PARAMETER Floppy
    Add a floppy drive
.PARAMETER CD
    Add a CD drive
.PARAMETER Network
    Network to connect to
.PARAMETER NetworkAdapterType
    Network adapter type
.PARAMETER GuestId
    Guest OS identifier
.PARAMETER OSCustomizationSpec
    Customization specification to apply
.PARAMETER HardwareVersion
    Hardware version
.PARAMETER Location
    Folder to place the VM
.PARAMETER Datastore
    Datastore for the VM
.PARAMETER VMSwapfilePolicy
    Swapfile policy: WithVM, Inherit, InHostDatastore
.EXAMPLE
    PS> ./New-VirtualMachine.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esx01.contoso.com" -VMName "NewVM" -MemoryGB 4 -DiskGB 40 -CD -Network "VM Network"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [string]$Notes,
    [int32]$Cpus = 1,
    [int32]$CoresPerSocket = 1,
    [decimal]$MemoryGB,
    [decimal]$DiskGB,
    [ValidateSet("Thin", "Thick", "EagerZeroedThick")]
    [string]$DiskStorageFormat = "Thick",
    [switch]$Floppy,
    [switch]$CD,
    [string]$Network,
    [ValidateSet("e1000", "Flexible", "Vmxnet", "EnhancedVmxnet", "Vmxnet3")]
    [string]$NetworkAdapterType = "e1000",
    [string]$GuestId,
    [string]$OSCustomizationSpec,
    [string]$HardwareVersion,
    [string]$Location,
    [string]$Datastore,
    [ValidateSet("WithVM", "Inherit", "InHostDatastore")]
    [string]$VMSwapfilePolicy = "Inherit"
)
Process {
    try {
        [string[]]$Properties = @('Name', 'Id', 'NumCpu', 'CoresPerSocket', 'Notes', 'GuestId', 'MemoryGB', 'VMSwapfilePolicy', 'ProvisionedSpaceGB', 'Folder')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Name = $VMName; VMHost = $vmHost; Notes = if ([System.String]::IsNullOrWhiteSpace($Notes)) { ' ' } else { $Notes }; Confirm = $false; NumCpu = $Cpus; CoresPerSocket = $CoresPerSocket; MemoryGB = $MemoryGB; DiskGB = $DiskGB; Floppy = $Floppy; CD = $CD; DiskStorageFormat = $DiskStorageFormat; VMSwapfilePolicy = $VMSwapfilePolicy }
        if (-not [System.String]::IsNullOrEmpty($Datastore)) { $store = Get-Datastore -Server $vmServer -Name $Datastore -ErrorAction Stop; $cmdArgs.Add('Datastore', $store) }
        if (-not [System.String]::IsNullOrEmpty($Location)) { $folder = Get-Folder -Server $vmServer -Name $Location -ErrorAction Stop; $cmdArgs.Add('Location', $folder) }
        if ($PSBoundParameters.ContainsKey('OSCustomizationSpec')) { $spec = Get-OSCustomizationSpec -Name $OSCustomizationSpec -Server $vmServer -ErrorAction Stop; $cmdArgs.Add('OSCustomizationSpec', $spec) }
        $machine = New-VM @cmdArgs
        if ($PSBoundParameters.ContainsKey('GuestId')) { $null = Set-VM -Server $vmServer -VM $machine -GuestId $GuestId -Confirm:$False -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('HardwareVersion')) { $null = Set-VM -Server $vmServer -VM $machine -HardwareVersion $HardwareVersion -Confirm:$False -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('Network')) { $adapter = Get-NetworkAdapter -Server $vmServer -VM $machine -ErrorAction Stop; $null = Set-NetworkAdapter -NetworkName $Network -NetworkAdapter $adapter -Type $NetworkAdapterType -Confirm:$false -ErrorAction Stop }
        $result = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}