#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the PCI devices on the specified hosts
.DESCRIPTION
    Retrieves PCI devices from hosts, optionally filtered by class name or device name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to retrieve the devices; retrieves all if empty
.PARAMETER ClassName
    Limits results to devices of the specified class
.PARAMETER DeviceName
    Filters the PCI devices by name
.EXAMPLE
    PS> ./Get-HostPCIDevice.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [string]$ClassName,
    [string]$DeviceName
)
Process {
    $vmServer = $null
    try {
        if ([System.String]::IsNullOrWhiteSpace($DeviceName)) { $DeviceName = "*" }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ([System.String]::IsNullOrWhiteSpace($ClassName)) {
            $result = Get-VMHostPciDevice -Server $vmServer -VMHost $HostName -Name $DeviceName -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-VMHostPciDevice -Server $vmServer -DeviceClass $ClassName -VMHost $HostName -Name $DeviceName -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
