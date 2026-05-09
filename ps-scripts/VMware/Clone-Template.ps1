#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a template by cloning an existing template
.DESCRIPTION
    Clones an existing template to create a new one on a specified host and datastore.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TemplateName
    Name of the new template
.PARAMETER SourceTemplateID
    ID of the source template
.PARAMETER SourceTemplateName
    Name of the source template
.PARAMETER DiskStorageFormat
    Disk storage format: Thin, Thick, EagerZeroedThick
.PARAMETER Datastore
    Datastore to store the new template
.PARAMETER Datacenter
    Datacenter to place the new template
.PARAMETER VMHost
    Host to store the new template
.EXAMPLE
    PS> ./Clone-Template.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -TemplateName "CloneTemplate" -SourceTemplateName "BaseTemplate" -Datastore "DS01" -Datacenter "DC01" -VMHost "esx01.contoso.com"
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
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$SourceTemplateID,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$SourceTemplateName,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$Datastore,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$Datacenter,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VMHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Thin", "Thick", "EagerZeroedThick")]
    [string]$DiskStorageFormat = "Thick"
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") { $source = Get-Template -Server $vmServer -Id $SourceTemplateID -ErrorAction Stop }
        else { $source = Get-Template -Name $SourceTemplateName -Server $vmServer -ErrorAction Stop }
        $store = Get-Datastore -Name $Datastore -Server $vmServer -ErrorAction Stop
        $center = Get-Datacenter -Name $Datacenter -Server $vmServer -ErrorAction Stop
        $vmhost = Get-VMHost -Server $vmServer -Name $VMHost -ErrorAction Stop
        $result = New-Template -Name $TemplateName -Template $source -Location $center -VMHost $vmhost -Datastore $store -Confirm:$false -Server $vmServer -DiskStorageFormat $DiskStorageFormat -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}