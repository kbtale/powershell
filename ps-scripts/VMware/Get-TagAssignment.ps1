#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves tag assignments of objects
.DESCRIPTION
    Retrieves tag assignments by entity name, entity type, or category.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER EntityName
    Object name to get tag assignments for
.PARAMETER EntityType
    Object type: Cluster, Datacenter, Datastore, Folder, ResourcePool, VM, VMHost, etc.
.PARAMETER Category
    Name of the tag category
.PARAMETER Properties
    List of properties to expand; use * for all
.EXAMPLE
    PS> ./Get-TagAssignment.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -EntityName "WebServer01" -EntityType "VM"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$EntityName,
    [ValidateSet('Cluster', 'Datacenter', 'Datastore', 'DatastoreCluster', 'Folder', 'ResourcePool', 'VApp', 'VM', 'VMHost')]
    [string]$EntityType = 'VM',
    [string]$Category,
    [ValidateSet('*', 'Name', 'Id', 'Entity', 'Tag', 'Uid')]
    [string[]]$Properties = @('Entity', 'Tag')
)
Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSBoundParameters.ContainsKey('EntityName')) {
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
            $cmdArgs.Add('Entity', $entity)
        }
        if ($PSBoundParameters.ContainsKey('Category')) { $cat = Get-TagCategory @cmdArgs -Name $Category -ErrorAction Stop; $cmdArgs.Add('Category', $cat) }
        $result = Get-TagAssignment @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}