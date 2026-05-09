#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies a tag category
.DESCRIPTION
    Renames, changes description, cardinality, or entity types of a tag category.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the tag category to modify
.PARAMETER NewName
    New name for the tag category
.PARAMETER Description
    New description
.PARAMETER Cardinality
    Cardinality: Single or Multi
.PARAMETER EntityType
    Entity types to add
.EXAMPLE
    PS> ./Set-TagCategory.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "Environment" -NewName "AppEnvironment"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$NewName,
    [string]$Description,
    [ValidateSet("Multi", "Single")]
    [string]$Cardinality,
    [ValidateSet('All', 'Cluster', 'Datacenter', 'Datastore', 'DatastoreCluster', 'DistributedPortGroup', 'DistributedSwitch', 'Folder', 'ResourcePool', 'VApp', 'VirtualPortGroup', 'VirtualMachine', 'VM', 'VMHost')]
    [string[]]$EntityType
)
Process {
    try {
        if ($EntityType -contains 'All') { $EntityType = @('All') }
        [string[]]$Properties = @('Name', 'Description', 'Cardinality', 'EntityType', 'Id')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        $cat = Get-TagCategory @cmdArgs -Name $Name -ErrorAction Stop
        $cmdArgs.Add('Category', $cat)
        if ($PSBoundParameters.ContainsKey('NewName')) { $cmdArgs.Add('Name', $NewName) }
        if ($PSBoundParameters.ContainsKey('Description')) { $cmdArgs.Add('Description', $Description) }
        if ($PSBoundParameters.ContainsKey('Cardinality')) { $cmdArgs.Add('Cardinality', $Cardinality) }
        if ($PSBoundParameters.ContainsKey('EntityType')) { $cmdArgs.Add('AddEntityType', $EntityType) }
        $result = Set-TagCategory @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}