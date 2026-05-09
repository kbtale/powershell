#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the specified virtual machine snapshot
.DESCRIPTION
    Modifies a snapshot's name or description.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER SnapShotName
    Name of the snapshot to modify
.PARAMETER NewName
    New name for the snapshot
.PARAMETER NewDescription
    New description for the snapshot
.EXAMPLE
    PS> ./Set-SnapShot.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -SnapShotName "Backup1" -NewName "Archived"
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
    [string]$NewName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewDescription
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Created', 'PowerState', 'SizeGB', 'Description', 'IsCurrent', 'Id')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
        }
        else {
            $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        }
        $snapshot = Get-Snapshot -Server $vmServer -VM $machine -Name $SnapShotName -ErrorAction Stop
        $output = $snapshot
        if ($PSBoundParameters.ContainsKey('NewName')) {
            $output = Set-Snapshot -Snapshot $snapshot -Name $NewName -Confirm:$false -ErrorAction Stop | Select-Object $Properties
        }
        if ($PSBoundParameters.ContainsKey('NewDescription')) {
            $output = Set-Snapshot -Snapshot $snapshot -Description $NewDescription -Confirm:$false -ErrorAction Stop | Select-Object $Properties
        }
        foreach ($item in $output) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
