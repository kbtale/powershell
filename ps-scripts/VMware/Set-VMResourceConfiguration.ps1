#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Configures resource allocation between the virtual machine
.DESCRIPTION
    Configures CPU and memory resource allocation for a VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER DiskName
    Name of the virtual hard disk to configure
.PARAMETER CpuLimitMhz
    CPU usage limit in MHz
.PARAMETER CpuReservationMhz
    Guaranteed CPU MHz
.PARAMETER CpuSharesLevel
    CPU allocation level
.PARAMETER MemLimitGB
    Memory usage limit in GB
.PARAMETER MemReservationGB
    Guaranteed memory in GB
.PARAMETER MemSharesLevel
    Memory allocation level
.PARAMETER NumCpuShares
    Number of CPU shares
.PARAMETER NumMemShares
    Number of memory shares
.EXAMPLE
    PS> ./Set-VMResourceConfiguration.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -CpuLimitMhz 2000
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
    [string]$DiskName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int64]$CpuLimitMhz,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int64]$CpuReservationMhz,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$CpuSharesLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [decimal]$MemLimitGB,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [decimal]$MemReservationGB,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$MemSharesLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$NumCpuShares,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$NumMemShares
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        $disk = $null
        $resConfig = Get-VMResourceConfiguration -Server $vmServer -VM $machine -ErrorAction Stop
        if (-not [System.String]::IsNullOrWhiteSpace($DiskName)) {
            $disk = Get-HardDisk -VM $machine -Name $DiskName -Server $vmServer -ErrorAction Stop
        }
        $cmdArgs = @{ ErrorAction = 'Stop'; Configuration = $resConfig; Confirm = $false }
        if ($null -ne $disk) { $cmdArgs.Add('Disk', $disk) }
        if ($PSBoundParameters.ContainsKey('CpuLimitMhz')) { $resConfig = Set-VMResourceConfiguration @cmdArgs -CpuLimitMhz $CpuLimitMhz }
        if ($PSBoundParameters.ContainsKey('CpuReservationMhz')) { $resConfig = Set-VMResourceConfiguration @cmdArgs -CpuReservationMhz $CpuReservationMhz }
        if ($PSBoundParameters.ContainsKey('CpuSharesLevel')) { $resConfig = Set-VMResourceConfiguration @cmdArgs -CpuSharesLevel $CpuSharesLevel }
        if ($PSBoundParameters.ContainsKey('MemLimitGB')) { $resConfig = Set-VMResourceConfiguration @cmdArgs -MemLimitGB $MemLimitGB }
        if ($PSBoundParameters.ContainsKey('MemReservationGB')) { $resConfig = Set-VMResourceConfiguration @cmdArgs -MemReservationGB $MemReservationGB }
        if ($PSBoundParameters.ContainsKey('MemSharesLevel')) { $resConfig = Set-VMResourceConfiguration @cmdArgs -MemSharesLevel $MemSharesLevel }
        if ($PSBoundParameters.ContainsKey('NumCpuShares')) { $resConfig = Set-VMResourceConfiguration @cmdArgs -NumCpuShares $NumCpuShares }
        if ($PSBoundParameters.ContainsKey('NumMemShares')) { $resConfig = Set-VMResourceConfiguration @cmdArgs -NumMemShares $NumMemShares }
        $result = $resConfig | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
