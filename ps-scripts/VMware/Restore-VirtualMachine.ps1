#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Reverts the VM to the specified snapshot
.DESCRIPTION
    Restores a virtual machine to a specified snapshot state.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER SnapShotName
    Name of the snapshot to restore
.EXAMPLE
    PS> ./Restore-VirtualMachine.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -SnapShotName "Backup1"
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
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$SnapShotName
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Id', 'PowerState', 'NumCpu', 'Notes', 'Guest', 'GuestId', 'MemoryMB', 'UsedSpaceGB', 'ProvisionedSpaceGB', 'Folder')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        $snapshot = Get-Snapshot -Server $vmServer -VM $machine -Name $SnapShotName -ErrorAction Stop
        $result = Set-VM -Server $vmServer -VM $machine -Snapshot $snapshot -Confirm:$false -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
