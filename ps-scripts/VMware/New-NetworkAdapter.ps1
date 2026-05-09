#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new virtual network adapter
.DESCRIPTION
    Creates a virtual network adapter attached to a VM via network name, port group, or distributed switch.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine to attach the new network adapter to
.PARAMETER Network
    Name of the network to connect to
.PARAMETER PortGroupName
    Standard or distributed port group name
.PARAMETER SwitchName
    Virtual switch to connect to
.PARAMETER PortID
    Port of the specified distributed switch
.PARAMETER MacAddress
    Optional MAC address for the adapter
.PARAMETER AdapterType
    Type of the network adapter
.PARAMETER StartConnected
    Start connected when VM powers on
.PARAMETER WakeOnLan
    Enable Wake-on-LAN
.EXAMPLE
    PS> ./New-NetworkAdapter.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01" -Network "VM Network"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "Default")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [Parameter(Mandatory = $true, ParameterSetName = "Switch")]
    [Parameter(Mandatory = $true, ParameterSetName = "PortGroup")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [Parameter(Mandatory = $true, ParameterSetName = "Switch")]
    [Parameter(Mandatory = $true, ParameterSetName = "PortGroup")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [Parameter(Mandatory = $true, ParameterSetName = "Switch")]
    [Parameter(Mandatory = $true, ParameterSetName = "PortGroup")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [string]$Network,
    [Parameter(Mandatory = $true, ParameterSetName = "PortGroup")]
    [string]$PortGroupName,
    [Parameter(Mandatory = $true, ParameterSetName = "Switch")]
    [string]$SwitchName,
    [Parameter(Mandatory = $true, ParameterSetName = "Switch")]
    [string]$PortID,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Switch")]
    [Parameter(ParameterSetName = "PortGroup")]
    [ValidateSet('e1000', 'Flexible', 'Vmxnet', 'EnhancedVmxnet', 'Vmxnet3')]
    [string]$AdapterType,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Switch")]
    [Parameter(ParameterSetName = "PortGroup")]
    [string]$MacAddress,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Switch")]
    [Parameter(ParameterSetName = "PortGroup")]
    [switch]$StartConnected,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Switch")]
    [Parameter(ParameterSetName = "PortGroup")]
    [switch]$WakeOnLan
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $vm = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        $newArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; VM = $vm; StartConnected = $StartConnected; WakeOnLan = $WakeOnLan }
        if ($PSCmdlet.ParameterSetName -eq "Switch") {
            $vdSwitch = Get-VDSwitch -Name $SwitchName -Server $vmServer -ErrorAction Stop
            $adapter = New-NetworkAdapter @newArgs -DistributedSwitch $vdSwitch -PortId $PortID
        }
        elseif ($PSCmdlet.ParameterSetName -eq "PortGroup") {
            $vdGroup = Get-VDPortgroup -Name $PortGroupName -Server $vmServer -ErrorAction Stop
            $adapter = New-NetworkAdapter @newArgs -Portgroup $vdGroup
        }
        else { $adapter = New-NetworkAdapter @newArgs -NetworkName $Network }
        $setArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; NetworkAdapter = $adapter; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('AdapterType')) { $null = Set-NetworkAdapter @setArgs -Type $AdapterType }
        if ($PSBoundParameters.ContainsKey('MacAddress')) { $null = Set-NetworkAdapter @setArgs -MacAddress $MacAddress }
        $result = Get-NetworkAdapter -Server $vmServer -VM $vm -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}