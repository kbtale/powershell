#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes a virtual floppy drive
.DESCRIPTION
    Removes a virtual floppy drive from a VM, template, or snapshot.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine from which to remove the floppy drive
.PARAMETER TemplateName
    Virtual machine template from which to remove the floppy drive
.PARAMETER SnapshotName
    Snapshot from which to remove the floppy drive
.EXAMPLE
    PS> ./Remove-FloppyDrive.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "VM")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "VM")]
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "Template")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true, ParameterSetName = "Snapshot")]
    [string]$SnapshotName
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSCmdlet.ParameterSetName -eq "Snapshot") { $vm = Get-VM @cmdArgs -Name $VMName; $snap = Get-Snapshot @cmdArgs -Name $SnapshotName -VM $vm; $cmdArgs.Add('Snapshot', $snap) }
        elseif ($PSCmdlet.ParameterSetName -eq "Template") { $temp = Get-Template @cmdArgs -Name $TemplateName; $cmdArgs.Add('Template', $temp) }
        else { $vm = Get-VM @cmdArgs -Name $VMName; $cmdArgs.Add('VM', $vm) }
        $floppy = Get-FloppyDrive @cmdArgs -ErrorAction Stop
        if ($null -eq $floppy) { throw "No floppy drive found" }
        $null = Remove-FloppyDrive -Floppy $floppy -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Floppy drive $($floppy.Name) successfully removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}