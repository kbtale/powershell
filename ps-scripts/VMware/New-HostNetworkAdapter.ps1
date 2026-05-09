#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new HostVirtualNIC on the specified host
.DESCRIPTION
    Creates a new service console or VMKernel network adapter on a virtual switch.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host whose network adapter to add
.PARAMETER SwitchName
    Name of the virtual switch to add the adapter to
.PARAMETER PortGroup
    Port group for the new adapter
.PARAMETER AutomaticIPv6
    IPv6 address obtained through router advertisement
.PARAMETER ConsoleNic
    Create a service console virtual network adapter
.PARAMETER Dhcp
    Use DHCP server
.PARAMETER FaultToleranceLoggingEnabled
    Enable Fault Tolerance logging
.PARAMETER IPv4
    IPv4 address
.PARAMETER IPv6
    IPv6 address
.PARAMETER IPv6Enabled
    Enable IPv6 configuration
.PARAMETER IPv6ThroughDhcp
    IPv6 address via DHCP
.PARAMETER MACAddress
    MAC address of the adapter
.PARAMETER ManagementTrafficEnabled
    Enable for management traffic
.PARAMETER MtuSize
    MTU size
.PARAMETER SubnetMask
    Subnet mask
.PARAMETER VMotionEnabled
    Enable for VMotion
.PARAMETER VsanTrafficEnabled
    Enable Virtual SAN traffic
.EXAMPLE
    PS> ./New-HostNetworkAdapter.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -SwitchName "vSwitch0" -PortGroup "Mgmt"
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
    [string]$SwitchName,
    [Parameter(Mandatory = $true)]
    [string]$PortGroup,
    [bool]$AutomaticIPv6,
    [switch]$Dhcp,
    [bool]$FaultToleranceLoggingEnabled,
    [string]$IPv4,
    [string]$IPv6,
    [bool]$IPv6Enabled,
    [bool]$IPv6ThroughDhcp,
    [string]$MACAddress,
    [bool]$ManagementTrafficEnabled,
    [int32]$MtuSize,
    [string]$SubnetMask,
    [bool]$VMotionEnabled,
    [bool]$VsanTrafficEnabled,
    [switch]$ConsoleNic
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $vSwitch = Get-VirtualSwitch -VMHost $vmHost -Name $SwitchName -ErrorAction Stop
        $vAdapter = New-VMHostNetworkAdapter -VMHost $vmHost -VirtualSwitch $vSwitch -ConsoleNic:$ConsoleNic -AutomaticIPv6:$AutomaticIPv6 -PortGroup $PortGroup -IPv6ThroughDhcp:$IPv6ThroughDhcp -Confirm:$false -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; VirtualNic = $vAdapter; Confirm = $false }
        $output = $null
        if ($PSBoundParameters.ContainsKey('Dhcp')) { $output = Set-VMHostNetworkAdapter @cmdArgs -Dhcp:$Dhcp -Confirm:$false -ErrorAction Stop | Select-Object * }
        if ($PSBoundParameters.ContainsKey('FaultToleranceLoggingEnabled')) { $output = Set-VMHostNetworkAdapter @cmdArgs -FaultToleranceLoggingEnabled $FaultToleranceLoggingEnabled -Confirm:$false -ErrorAction Stop | Select-Object * }
        if ($PSBoundParameters.ContainsKey('IPv4')) { $output = Set-VMHostNetworkAdapter @cmdArgs -IP $IPv4 | Select-Object * }
        if ($PSBoundParameters.ContainsKey('IPv6')) { $output = Set-VMHostNetworkAdapter @cmdArgs -IPv6 $IPv6 | Select-Object * }
        if ($PSBoundParameters.ContainsKey('IPv6ThroughDhcp')) { $output = Set-VMHostNetworkAdapter @cmdArgs -IPv6ThroughDhcp $IPv6ThroughDhcp | Select-Object * }
        if ($PSBoundParameters.ContainsKey('MACAddress')) { $output = Set-VMHostNetworkAdapter @cmdArgs -MAC $MACAddress | Select-Object * }
        if ($PSBoundParameters.ContainsKey('ManagementTrafficEnabled')) { $output = Set-VMHostNetworkAdapter @cmdArgs -ManagementTrafficEnabled $ManagementTrafficEnabled | Select-Object * }
        if ($PSBoundParameters.ContainsKey('MtuSize')) { $output = Set-VMHostNetworkAdapter @cmdArgs -Mtu $MtuSize | Select-Object * }
        if ($PSBoundParameters.ContainsKey('SubnetMask')) { $output = Set-VMHostNetworkAdapter @cmdArgs -SubnetMask $SubnetMask | Select-Object * }
        if ($PSBoundParameters.ContainsKey('VMotionEnabled')) { $output = Set-VMHostNetworkAdapter @cmdArgs -VMotionEnabled $VMotionEnabled | Select-Object * }
        if ($PSBoundParameters.ContainsKey('VsanTrafficEnabled')) { $output = Set-VMHostNetworkAdapter @cmdArgs -VsanTrafficEnabled $VsanTrafficEnabled | Select-Object * }
        if ($PSBoundParameters.ContainsKey('IPv6Enabled')) { $output = Set-VMHostNetworkAdapter @cmdArgs -IPv6Enabled $IPv6Enabled | Select-Object * }
        if ($null -ne $output) {
            foreach ($item in $output) {
                $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
                Write-Output $item
            }
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
