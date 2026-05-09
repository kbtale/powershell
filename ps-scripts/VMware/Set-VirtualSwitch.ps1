#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the properties of a virtual switch
.DESCRIPTION
    Modifies port count or MTU of a virtual switch.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the virtual switch
.PARAMETER PortNumber
    Number of ports
.PARAMETER Mtu
    Maximum transmission unit in bytes
.EXAMPLE
    PS> ./Set-VirtualSwitch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "vSwitch1" -Mtu 9000
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [int32]$PortNumber,
    [int32]$Mtu
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $vswitch = Get-VirtualSwitch -Server $vmServer -Name $Name -ErrorAction Stop
        if ($PortNumber -gt 0) { $vswitch = Set-VirtualSwitch -VirtualSwitch $vswitch -Server $vmServer -NumPorts $PortNumber -Confirm:$false -ErrorAction Stop | Select-Object * }
        if ($Mtu -gt 0) { $vswitch = Set-VirtualSwitch -VirtualSwitch $vswitch -Server $vmServer -Mtu $Mtu -Confirm:$false -ErrorAction Stop | Select-Object * }
        $result = $vswitch | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}