#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new resource pool
.DESCRIPTION
    Creates a new resource pool on a specified host with CPU and memory settings.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name for the new resource pool
.PARAMETER VMHost
    Host on which to create the resource pool
.PARAMETER CpuExpandableReservation
    CPU reservation can grow beyond the specified value
.PARAMETER CpuLimitMhz
    CPU usage limit in MHz
.PARAMETER CpuReservationMhz
    Guaranteed CPU in MHz
.PARAMETER CpuSharesLevel
    CPU allocation level: Custom, High, Low, Normal
.PARAMETER MemExpandableReservation
    Memory reservation can grow beyond the specified value
.PARAMETER MemLimitGB
    Memory usage limit in GB
.PARAMETER MemReservationGB
    Guaranteed memory in GB
.PARAMETER MemSharesLevel
    Memory allocation level: Custom, High, Low, Normal
.PARAMETER NumCpuShares
    Number of CPU shares (used with Custom level)
.PARAMETER NumMemShares
    Number of memory shares (used with Custom level)
.EXAMPLE
    PS> ./New-ResourcePool.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "TestPool" -VMHost "esx01.contoso.com"
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
    [Parameter(Mandatory = $true)]
    [string]$VMHost,
    [bool]$CpuExpandableReservation,
    [int64]$CpuLimitMhz,
    [int64]$CpuReservationMhz,
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$CpuSharesLevel,
    [bool]$MemExpandableReservation,
    [decimal]$MemLimitGB,
    [decimal]$MemReservationGB,
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$MemSharesLevel,
    [int32]$NumCpuShares,
    [int32]$NumMemShares
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $pool = New-ResourcePool -Server $vmServer -Location $VMHost -Name $Name -Confirm:$false -ErrorAction Stop
        $setArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; ResourcePool = $pool; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('CpuExpandableReservation')) { $pool = Set-ResourcePool @setArgs -CpuExpandableReservation $CpuExpandableReservation }
        if ($PSBoundParameters.ContainsKey('CpuLimitMhz')) { $pool = Set-ResourcePool @setArgs -CpuLimitMhz $CpuLimitMhz }
        if ($PSBoundParameters.ContainsKey('CpuReservationMhz')) { $pool = Set-ResourcePool @setArgs -CpuReservationMhz $CpuReservationMhz }
        if ($PSBoundParameters.ContainsKey('CpuSharesLevel')) { $pool = Set-ResourcePool @setArgs -CpuSharesLevel $CpuSharesLevel }
        if ($PSBoundParameters.ContainsKey('MemExpandableReservation')) { $pool = Set-ResourcePool @setArgs -MemExpandableReservation $MemExpandableReservation }
        if ($PSBoundParameters.ContainsKey('MemLimitGB')) { $pool = Set-ResourcePool @setArgs -MemLimitGB $MemLimitGB }
        if ($PSBoundParameters.ContainsKey('MemReservationGB')) { $pool = Set-ResourcePool @setArgs -MemReservationGB $MemReservationGB }
        if ($PSBoundParameters.ContainsKey('MemSharesLevel')) { $pool = Set-ResourcePool @setArgs -MemSharesLevel $MemSharesLevel }
        if ($PSBoundParameters.ContainsKey('NumCpuShares')) { $pool = Set-ResourcePool @setArgs -NumCpuShares $NumCpuShares }
        if ($PSBoundParameters.ContainsKey('NumMemShares')) { $pool = Set-ResourcePool @setArgs -NumMemShares $NumMemShares }
        $result = $pool | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}