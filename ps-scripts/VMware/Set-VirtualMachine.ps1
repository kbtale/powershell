#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the configuration of a virtual machine
.DESCRIPTION
    Modifies CPU, memory, network, guest OS, and other settings of a VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the VM
.PARAMETER VMName
    Name of the VM
.PARAMETER Notes
    New description
.PARAMETER Cpus
    Number of virtual CPUs
.PARAMETER CoresPerSocket
    Number of cores per socket
.PARAMETER MemoryGB
    Memory size in GB
.PARAMETER Network
    Network to connect to
.PARAMETER GuestId
    Guest OS identifier
.PARAMETER OSCustomizationSpec
    Customization specification
.PARAMETER HardwareVersion
    Hardware version
.PARAMETER VMSwapfilePolicy
    Swapfile policy: WithVM, Inherit, InHostDatastore
.PARAMETER NewName
    New name for the VM
.EXAMPLE
    PS> ./Set-VirtualMachine.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01" -Cpus 4 -MemoryGB 8
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
    [string]$Notes,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$Cpus,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$CoresPerSocket,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [decimal]$MemoryGB,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$Network,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$GuestId,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$OSCustomizationSpec,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$HardwareVersion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("WithVM", "Inherit", "InHostDatastore")]
    [string]$VMSwapfilePolicy,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewName
)
Process {
    try {
        [string[]]$Properties = @('Name', 'Id', 'NumCpu', 'CoresPerSocket', 'Notes', 'GuestId', 'MemoryGB', 'VMSwapfilePolicy', 'ProvisionedSpaceGB', 'Folder')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") { $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop }
        else { $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop }
        $setArgs = @{ Server = $vmServer; VM = $machine; Confirm = $false; ErrorAction = 'Stop' }
        if ($Cpus -gt 0) { $null = Set-VM @setArgs -NumCpu $Cpus }
        if ($CoresPerSocket -gt 0) { $null = Set-VM @setArgs -CoresPerSocket $CoresPerSocket }
        if ($MemoryGB -gt 0) { $null = Set-VM @setArgs -MemoryGB $MemoryGB }
        if ($PSBoundParameters.ContainsKey('Notes')) { $null = Set-VM @setArgs -Notes $Notes }
        if ($PSBoundParameters.ContainsKey('GuestId')) { $null = Set-VM @setArgs -GuestId $GuestId }
        if ($PSBoundParameters.ContainsKey('OSCustomizationSpec')) { $spec = Get-OSCustomizationSpec -Name $OSCustomizationSpec -Server $vmServer -ErrorAction Stop; $null = Set-VM @setArgs -OSCustomizationSpec $spec }
        if ($PSBoundParameters.ContainsKey('HardwareVersion')) { $null = Set-VM @setArgs -HardwareVersion $HardwareVersion }
        if ($PSBoundParameters.ContainsKey('Network')) { $adapter = Get-NetworkAdapter -Server $vmServer -VM $machine -ErrorAction Stop; $null = Set-NetworkAdapter -NetworkName $Network -NetworkAdapter $adapter -Confirm:$false -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('VMSwapfilePolicy')) { $null = Set-VM @setArgs -VMSwapfilePolicy $VMSwapfilePolicy }
        if ($PSBoundParameters.ContainsKey('NewName')) { $null = Set-VM @setArgs -Name $NewName }
        $result = Get-VM -Server $vmServer -ID $machine.Id -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}