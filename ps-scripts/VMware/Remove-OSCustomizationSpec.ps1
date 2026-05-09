#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes an OS customization specification
.DESCRIPTION
    Removes an OS customization specification by name or ID.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the OS customization specification
.PARAMETER SpecName
    Name of the OS customization specification
.EXAMPLE
    PS> ./Remove-OSCustomizationSpec.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -SpecName "OldSpec"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "ByName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]
    [Parameter(Mandatory = $true, ParameterSetName = "ById")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]
    [Parameter(Mandatory = $true, ParameterSetName = "ById")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "ById")]
    [string]$ID,
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]
    [string]$SpecName
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSCmdlet.ParameterSetName -eq "ById") { $spec = Get-OSCustomizationSpec @cmdArgs -ID $ID -ErrorAction Stop }
        else { $spec = Get-OSCustomizationSpec @cmdArgs -Name $SpecName -ErrorAction Stop }
        if ($null -eq $spec) { throw "OS customization specification not found" }
        $null = Remove-OSCustomizationSpec @cmdArgs -OSCustomizationSpec $spec -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "OS customization specification successfully removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}