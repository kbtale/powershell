#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes the specified resource pool
.DESCRIPTION
    Removes a resource pool by ID or name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the resource pool to remove
.PARAMETER Name
    Name of the resource pool to remove
.EXAMPLE
    PS> ./Remove-ResourcePool.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "OldPool"
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
    [string]$ID,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$Name
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") { $pool = Get-ResourcePool -Server $vmServer -ID $ID -ErrorAction Stop }
        else { $pool = Get-ResourcePool -Server $vmServer -Name $Name -ErrorAction Stop }
        if ($null -eq $pool) { throw "Resource pool not found" }
        $null = Remove-ResourcePool -ResourcePool $pool -Server $vmServer -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Resource pool $($pool.Name) removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}