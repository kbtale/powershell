#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Sets the distributed switch and port of a virtual network adapter
.DESCRIPTION
    Assigns a distributed switch and port to a virtual network adapter.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine whose network adapter to modify
.PARAMETER TemplateName
    Template whose network adapter to modify
.PARAMETER SnapshotName
    Snapshot whose network adapter to modify
.PARAMETER SwitchName
    Virtual switch to connect to
.PARAMETER PortID
    Port of the distributed switch
.PARAMETER AdapterName
    Name of the network adapter to modify
.PARAMETER AdapterType
    Type of the network adapter
.PARAMETER MacAddress
    Optional MAC address
.PARAMETER Connected
    Connect or disconnect the adapter
.PARAMETER StartConnected
    Start connected when VM powers on
.PARAMETER WakeOnLan
    Enable Wake-on-LAN
.EXAMPLE
    PS> ./Set-NetworkAdapterSwitch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01" -SwitchName "dvSwitch01" -PortID "101"
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
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$SwitchName,
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$PortID,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$AdapterName = '*',
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [ValidateSet('e1000', 'Flexible', 'Vmxnet', 'EnhancedVmxnet', 'Vmxnet3')]
    [string]$AdapterType,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$MacAddress,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$Connected,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$StartConnected,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$WakeOnLan
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSCmdlet.ParameterSetName -eq "Snapshot") { $vm = Get-VM @cmdArgs -Name $VMName; $snap = Get-Snapshot @cmdArgs -Name $SnapshotName -VM $vm; $cmdArgs.Add('Snapshot', $snap) }
        elseif ($PSCmdlet.ParameterSetName -eq "Template") { $temp = Get-Template @cmdArgs -Name $TemplateName; $cmdArgs.Add('Template', $temp) }
        else { $vm = Get-VM @cmdArgs -Name $VMName; $cmdArgs.Add('VM', $vm) }
        $adapter = Get-NetworkAdapter @cmdArgs -Name $AdapterName -ErrorAction Stop
        $vdSwitch = Get-VDSwitch -Name $SwitchName -Server $vmServer -ErrorAction Stop
        $setArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; NetworkAdapter = $adapter; Confirm = $false }
        $null = Set-NetworkAdapter @setArgs -DistributedSwitch $vdSwitch -PortId $PortID
        if ($PSBoundParameters.ContainsKey('AdapterType')) { $null = Set-NetworkAdapter @setArgs -Type $AdapterType }
        if ($PSBoundParameters.ContainsKey('MacAddress')) { $null = Set-NetworkAdapter @setArgs -MacAddress $MacAddress }
        if ($PSBoundParameters.ContainsKey('Connected')) { $null = Set-NetworkAdapter @setArgs -Connected $Connected }
        if ($PSBoundParameters.ContainsKey('StartConnected')) { $null = Set-NetworkAdapter @setArgs -StartConnected $StartConnected }
        if ($PSBoundParameters.ContainsKey('WakeOnLan')) { $null = Set-NetworkAdapter @setArgs -WakeOnLan $WakeOnLan }
        $result = Get-NetworkAdapter @cmdArgs -Name $adapter.Name -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}