#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes a tag assignment
.DESCRIPTION
    Removes a tag assignment from an entity.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Tag
    Name of the tag
.PARAMETER EntityName
    Object name to remove the tag from
.PARAMETER EntityType
    Object type: Cluster, Datacenter, Datastore, Folder, ResourcePool, VM, VMHost, etc.
.EXAMPLE
    PS> ./Remove-TagAssignment.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Tag "Production" -EntityName "WebServer01" -EntityType "VM"
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
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        $objTag = Get-Tag @cmdArgs -Name $Tag -ErrorAction Stop
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
        $null = Get-TagAssignment @cmdArgs -Entity $entity -ErrorAction Stop | Where-Object { $_.Tag -like "$($objTag.Category)/$($objTag.Name)" } | Remove-TagAssignment -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Tag assignment successfully removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}