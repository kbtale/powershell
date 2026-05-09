#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes a virtual switch
.DESCRIPTION
    Removes a virtual switch by ID or name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the virtual switch
.PARAMETER Name
    Name of the virtual switch
.EXAMPLE
    PS> ./Remove-VirtualSwitch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "vSwitch1"
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
        if ($PSCmdlet.ParameterSetName -eq "byID") { $vswitch = Get-VirtualSwitch -Server $vmServer -ID $ID -ErrorAction Stop }
        else { $vswitch = Get-VirtualSwitch -Server $vmServer -Name $Name -ErrorAction Stop }
        $null = Remove-VirtualSwitch -Server $vmServer -VirtualSwitch $vswitch -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Virtual switch $($vswitch.Name) removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}