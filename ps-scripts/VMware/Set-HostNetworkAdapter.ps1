#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Configures the specified host network adapter
.DESCRIPTION
    Configures a host network adapter's IP, MAC, MTU, and other settings.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host whose network adapter to modify
.PARAMETER AdapterName
    Name of the host network adapter to modify
.PARAMETER AutomaticIPv6
    IPv6 address obtained through router advertisement
.PARAMETER Dhcp
    Use DHCP for the host network adapter
.PARAMETER FaultToleranceLoggingEnabled
    Enable Fault Tolerance logging
.PARAMETER IPv4
    IPv4 address in dot notation
.PARAMETER IPv6
    IPv6 address
.PARAMETER IPv6Enabled
    Enable IPv6 configuration
.PARAMETER IPv6ThroughDhcp
    IPv6 address obtained through DHCP
.PARAMETER MACAddress
    MAC address of the virtual network adapter
.PARAMETER ManagementTrafficEnabled
    Enable the network adapter for management traffic
.PARAMETER MtuSize
    MTU size
.PARAMETER SubnetMask
    Subnet mask for the NIC
.PARAMETER VMotionEnabled
    Enable for VMotion
.PARAMETER VsanTrafficEnabled
    Enable Virtual SAN traffic
.EXAMPLE
    PS> ./Set-HostNetworkAdapter.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -AdapterName "vmk0" -IPv4 "10.0.0.10"
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
    [string]$AdapterName,
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
    [bool]$VsanTrafficEnabled
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vAdapter = Get-VMHostNetworkAdapter -Server $vmServer -Name $AdapterName -VMHost $HostName -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; VirtualNic = $vAdapter; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('AutomaticIPv6')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -AutomaticIPv6 $AutomaticIPv6 }
        if ($PSBoundParameters.ContainsKey('Dhcp')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -Dhcp:$Dhcp }
        if ($PSBoundParameters.ContainsKey('FaultToleranceLoggingEnabled')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -FaultToleranceLoggingEnabled $FaultToleranceLoggingEnabled }
        if ($PSBoundParameters.ContainsKey('IPv4')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -IP $IPv4 }
        if ($PSBoundParameters.ContainsKey('IPv6')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -IPv6 $IPv6 }
        if ($PSBoundParameters.ContainsKey('IPv6Enabled')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -IPv6Enabled $IPv6Enabled }
        if ($PSBoundParameters.ContainsKey('IPv6ThroughDhcp')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -IPv6ThroughDhcp $IPv6ThroughDhcp }
        if ($PSBoundParameters.ContainsKey('MACAddress')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -Mac $MACAddress }
        if ($PSBoundParameters.ContainsKey('ManagementTrafficEnabled')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -ManagementTrafficEnabled $ManagementTrafficEnabled }
        if ($PSBoundParameters.ContainsKey('MtuSize')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -Mtu $MtuSize }
        if ($PSBoundParameters.ContainsKey('SubnetMask')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -SubnetMask $SubnetMask }
        if ($PSBoundParameters.ContainsKey('VMotionEnabled')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -VMotionEnabled $VMotionEnabled }
        if ($PSBoundParameters.ContainsKey('VsanTrafficEnabled')) { $vAdapter = Set-VMHostNetworkAdapter @cmdArgs -VsanTrafficEnabled $VsanTrafficEnabled }
        $result = $vAdapter | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
