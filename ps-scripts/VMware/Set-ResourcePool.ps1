#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies a resource pool
.DESCRIPTION
    Modifies CPU and memory settings of a resource pool.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the resource pool to modify
.PARAMETER NewName
    New name for the resource pool
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
    PS> ./Set-ResourcePool.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "TestPool" -CpuLimitMhz 4000
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
    [bool]$CpuExpandableReservation,
    [int64]$CpuLimitMhz,
    [int64]$CpuReservationMhz,
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$CpuSharesLevel,
    [string]$NewName,
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
        $pool = Get-ResourcePool -Server $vmServer -Name $Name -ErrorAction Stop
        if ($null -eq $pool) { throw "Resource pool $Name not found" }
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
        if ($PSBoundParameters.ContainsKey('NewName')) { $pool = Set-ResourcePool @setArgs -Name $NewName }
        $result = $pool | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}