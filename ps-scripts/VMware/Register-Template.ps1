#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Registers a new template
.DESCRIPTION
    Registers a template from a datastore path.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TemplateName
    Name for the registered template
.PARAMETER TemplateFilePath
    Datastore path to the template file
.PARAMETER FolderName
    Folder where to place the template
.PARAMETER VMHost
    Host for the template
.EXAMPLE
    PS> ./Register-Template.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -TemplateName "Recovered" -TemplateFilePath "[DS01] template/template.vmtx" -FolderName "Templates" -VMHost "esx01.contoso.com"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$TemplateName,
    [Parameter(Mandatory = $true)]
    [string]$TemplateFilePath,
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [Parameter(Mandatory = $true)]
    [string]$VMHost
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $vmhost = Get-VMHost -Server $vmServer -Name $VMHost -ErrorAction Stop
        $folder = Get-Folder -Name $FolderName -Server $vmServer -ErrorAction Stop
        $result = New-Template -Name $TemplateName -TemplateFilePath $TemplateFilePath -Location $folder -VMHost $vmhost -Confirm:$false -Server $vmServer -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}