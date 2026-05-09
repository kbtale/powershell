#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Updates the specified virtual network
.DESCRIPTION
    Configures host networking settings including DNS, gateways, and IPv6.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host whose networking configuration to modify
.PARAMETER ConsoleGateway
    New console gateway address
.PARAMETER ConsoleGatewayDevice
    New console gateway device
.PARAMETER ConsoleV6Gateway
    Console V6 gateway address
.PARAMETER ConsoleV6GatewayDevice
    Console V6 gateway device
.PARAMETER DnsAddress
    New DNS address
.PARAMETER DomainName
    New domain name
.PARAMETER IPv6Enabled
    Enable IPv6 configuration
.PARAMETER SearchDomain
    New search domain
.PARAMETER VMKernelGateway
    New kernel gateway
.PARAMETER VMKernelGatewayDevice
    New kernel gateway device
.PARAMETER VMKernelV6Gateway
    VMKernel V6 gateway address
.PARAMETER VMKernelV6GatewayDevice
    VMKernel V6 gateway device
.EXAMPLE
    PS> ./Set-HostNetwork.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -DnsAddress "10.0.0.1"
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
    [string]$ConsoleGateway,
    [string]$ConsoleGatewayDevice,
    [string]$ConsoleV6Gateway,
    [string]$ConsoleV6GatewayDevice,
    [string]$DnsAddress,
    [string]$DomainName,
    [bool]$IPv6Enabled,
    [string]$SearchDomain,
    [string]$VMKernelGateway,
    [string]$VMKernelGatewayDevice,
    [string]$VMKernelV6Gateway,
    [string]$VMKernelV6GatewayDevice
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $netInfo = Get-VMHostNetwork -Server $vmServer -VMHost $vmHost -ErrorAction Stop
        $output = $netInfo | Select-Object *
        $cmdArgs = @{ ErrorAction = 'Stop'; Network = $netInfo; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('ConsoleGateway')) { $output = Set-VMHostNetwork @cmdArgs -ConsoleGateway $ConsoleGateway | Select-Object * }
        if ($PSBoundParameters.ContainsKey('ConsoleGatewayDevice')) { $output = Set-VMHostNetwork @cmdArgs -ConsoleGatewayDevice $ConsoleGatewayDevice | Select-Object * }
        if ($PSBoundParameters.ContainsKey('ConsoleV6Gateway')) { $output = Set-VMHostNetwork @cmdArgs -ConsoleV6Gateway $ConsoleV6Gateway | Select-Object * }
        if ($PSBoundParameters.ContainsKey('ConsoleV6GatewayDevice')) { $output = Set-VMHostNetwork @cmdArgs -ConsoleV6GatewayDevice $ConsoleV6GatewayDevice | Select-Object * }
        if ($PSBoundParameters.ContainsKey('DnsAddress')) { $output = Set-VMHostNetwork @cmdArgs -DnsAddress $DnsAddress | Select-Object * }
        if ($PSBoundParameters.ContainsKey('IPv6Enabled')) { $output = Set-VMHostNetwork @cmdArgs -IPv6Enabled $IPv6Enabled | Select-Object * }
        if ($PSBoundParameters.ContainsKey('VMKernelGateway')) { $output = Set-VMHostNetwork @cmdArgs -VMKernelGateway $VMKernelGateway | Select-Object * }
        if ($PSBoundParameters.ContainsKey('VMKernelGatewayDevice')) { $output = Set-VMHostNetwork @cmdArgs -VMKernelGatewayDevice $VMKernelGatewayDevice | Select-Object * }
        if ($PSBoundParameters.ContainsKey('VMKernelV6Gateway')) { $output = Set-VMHostNetwork @cmdArgs -VMKernelV6Gateway $VMKernelV6Gateway | Select-Object * }
        if ($PSBoundParameters.ContainsKey('VMKernelV6GatewayDevice')) { $output = Set-VMHostNetwork @cmdArgs -VMKernelV6GatewayDevice $VMKernelV6GatewayDevice | Select-Object * }
        if ($PSBoundParameters.ContainsKey('DomainName')) { $output = Set-VMHostNetwork @cmdArgs -DomainName $DomainName | Select-Object * }
        foreach ($item in $output) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
