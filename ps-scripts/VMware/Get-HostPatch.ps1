#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the host patches installed on the specified host
.DESCRIPTION
    Retrieves installed patches from a specified ESXi host using ESXCli.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host to retrieve patches from
.PARAMETER Properties
    List of properties to expand; use * for all properties
.EXAMPLE
    PS> ./Get-HostPatch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
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
    [ValidateSet('*', 'Name', 'InstallDate', 'AcceptanceLevel', 'CreationDate', 'ID', 'Status', 'Vendor', 'Version')]
    [string[]]$Properties = @('Name', 'InstallDate', 'AcceptanceLevel', 'CreationDate', 'ID', 'Status', 'Vendor', 'Version')
)
Process {
    $vmServer = $null
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $result = (Get-ESXCli -VMHost $vmHost).software.vib.list() | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
