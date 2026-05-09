#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the guest operating system of the specified virtual machine
.DESCRIPTION
    Retrieves guest OS information for a VM by ID or name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER Properties
    List of properties to expand; use * for all properties
.EXAMPLE
    PS> ./Get-GuestSystem.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM"
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
    [ValidateSet('*', 'OSFullName', 'State', 'IPAddress', 'Disks', 'ConfiguredGuestId', 'ToolsVersion')]
    [string[]]$Properties = @('OSFullName', 'State', 'IPAddress', 'Disks', 'ConfiguredGuestId', 'ToolsVersion')
)
Process {
    $vmServer = $null
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        $result = Get-VMGuest -VM $machine -Server $vmServer -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
