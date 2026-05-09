#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes the specified virtual machine snapshot
.DESCRIPTION
    Removes a snapshot by name from a VM, optionally removing children.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER SnapShotName
    Name of the snapshot to remove
.PARAMETER RemoveChildren
    Remove the children of the specified snapshot as well
.EXAMPLE
    PS> ./Remove-SnapShot.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -SnapShotName "Backup1"
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
    [string]$SnapShotName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$RemoveChildren
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        $snapshot = Get-Snapshot -Server $vmServer -VM $machine -Name $SnapShotName -ErrorAction Stop
        $null = Remove-Snapshot -Snapshot $snapshot -RemoveChildren:$RemoveChildren -Confirm:$false -ErrorAction Stop
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Snapshot $SnapShotName successfully removed"
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
