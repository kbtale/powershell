#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes a virtual machine template from the inventory
.DESCRIPTION
    Removes a template by ID or name with optional permanent deletion.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TemplateID
    ID of the template to remove
.PARAMETER TemplateName
    Name of the template to remove
.PARAMETER DeletePermanently
    Delete from the datastore as well as inventory
.EXAMPLE
    PS> ./Remove-Template.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -TemplateName "OldTemplate"
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
    [string]$TemplateID,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$TemplateName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$DeletePermanently
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") { $temp = Get-Template -Server $vmServer -Id $TemplateID -ErrorAction Stop }
        else { $temp = Get-Template -Server $vmServer -Name $TemplateName -ErrorAction Stop }
        $null = Remove-Template -Template $temp -DeletePermanently:$DeletePermanently -Server $vmServer -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Template $($temp.Name) successfully removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}