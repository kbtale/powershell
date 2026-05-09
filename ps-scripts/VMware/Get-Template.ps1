#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves virtual machine templates
.DESCRIPTION
    Retrieves templates by ID, name, or datastore.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TemplateID
    ID of the template
.PARAMETER TemplateName
    Name of the template; retrieves all if empty
.PARAMETER DatastoreName
    Name of the datastore where templates are stored
.PARAMETER NoRecursion
    Disable recursive behavior
.EXAMPLE
    PS> ./Get-Template.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$TemplateID,
    [Parameter(ParameterSetName = "byName")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [string]$DatastoreName,
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [switch]$NoRecursion
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $result = Get-Template -Server $vmServer -Id $TemplateID -ErrorAction Stop | Select-Object *
        }
        elseif ($PSCmdlet.ParameterSetName -eq "byName") {
            if ([System.String]::IsNullOrWhiteSpace($TemplateName)) { $result = Get-Template -Server $vmServer -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object * }
            else { $result = Get-Template -Server $vmServer -Name $TemplateName -ErrorAction Stop | Select-Object * }
        }
        else {
            $datastore = Get-Datastore -Server $vmServer -Name $DatastoreName -ErrorAction Stop
            $result = Get-Template -Server $vmServer -Datastore $datastore -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object *
        }
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}