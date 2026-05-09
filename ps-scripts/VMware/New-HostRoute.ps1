#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new route in the routing table of a host
.DESCRIPTION
    Creates a new route with specified destination, gateway, and prefix length.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to create a route
.PARAMETER Destination
    Destination IP address for the new route
.PARAMETER Gateway
    Gateway IP address for the new route
.PARAMETER PrefixLength
    Prefix length of the destination IP address
.EXAMPLE
    PS> ./New-HostRoute.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -Destination "10.0.0.0" -Gateway "10.0.0.1" -PrefixLength 24
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
    [string]$Destination,
    [Parameter(Mandatory = $true)]
    [string]$Gateway,
    [Parameter(Mandatory = $true)]
    [int32]$PrefixLength
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $result = New-VMHostRoute -VMHost $HostName -Destination $Destination -PrefixLength $PrefixLength -Gateway $Gateway -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
