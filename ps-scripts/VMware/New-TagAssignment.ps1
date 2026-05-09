#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Assigns a tag to an entity
.DESCRIPTION
    Assigns a tag to an object such as VM, Cluster, Datastore, etc.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Tag
    Name of the tag
.PARAMETER EntityName
    Object name to assign the tag to
.PARAMETER EntityType
    Object type: Cluster, Datacenter, Datastore, Folder, ResourcePool, VM, VMHost, etc.
.EXAMPLE
    PS> ./New-TagAssignment.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Tag "Production" -EntityName "WebServer01" -EntityType "VM"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Tag,
    [Parameter(Mandatory = $true)]
    [string]$EntityName,
    [ValidateSet('Cluster', 'Datacenter', 'Datastore', 'DatastoreCluster', 'Folder', 'ResourcePool', 'VApp', 'VM', 'VMHost')]
    [string]$EntityType = 'VM'
)
Process {
    try {
        [string[]]$Properties = @('Entity', 'Tag')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        $entity = switch ($EntityType) {
            'Cluster' { Get-Cluster @cmdArgs -Name $EntityName -ErrorAction Stop }
            'Datacenter' { Get-Datacenter @cmdArgs -Name $EntityName -ErrorAction Stop }
            'Datastore' { Get-Datastore @cmdArgs -Name $EntityName -ErrorAction Stop }
            'DatastoreCluster' { Get-DatastoreCluster @cmdArgs -Name $EntityName -ErrorAction Stop }
            'Folder' { Get-Folder @cmdArgs -Name $EntityName -ErrorAction Stop }
            'ResourcePool' { Get-ResourcePool @cmdArgs -Name $EntityName -ErrorAction Stop }
            'VApp' { Get-VApp @cmdArgs -Name $EntityName -ErrorAction Stop }
            'VM' { Get-VM @cmdArgs -Name $EntityName -ErrorAction Stop }
            'VMHost' { Get-VMHost @cmdArgs -Name $EntityName -ErrorAction Stop }
        }
        if ($null -eq $entity) { throw "Entity $EntityName of type $EntityType not found" }
        $objTag = Get-Tag @cmdArgs -Name $Tag -ErrorAction Stop
        $result = New-TagAssignment @cmdArgs -Tag $objTag -Entity $entity -Confirm:$false | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}