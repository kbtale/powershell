#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Converts a template to a virtual machine
.DESCRIPTION
    Converts a template to a VM by ID or name.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TemplateID
    ID of the template
.PARAMETER TemplateName
    Name of the template
.EXAMPLE
    PS> ./Convert-Template.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -TemplateName "OldTemplate"
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
    [string]$TemplateName
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") { $temp = Get-Template -Server $vmServer -Id $TemplateID -ErrorAction Stop }
        else { $temp = Get-Template -Server $vmServer -Name $TemplateName -ErrorAction Stop }
        $result = Set-Template -Template $temp -ToVM -Server $vmServer -Confirm:$false -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}