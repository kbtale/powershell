#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new tag category
.DESCRIPTION
    Creates a new tag category with specified cardinality and entity types.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the new tag category
.PARAMETER Description
    Description of the new tag category
.PARAMETER Cardinality
    Cardinality: Single or Multi
.PARAMETER EntityType
    Types of objects to which tags in this category apply
.EXAMPLE
    PS> ./New-TagCategory.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "Environment" -Cardinality "Single" -EntityType "VM"
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
    [string]$Description,
    [ValidateSet("Multi", "Single")]
    [string]$Cardinality = "Single",
    [ValidateSet('All', 'Cluster', 'Datacenter', 'Datastore', 'DatastoreCluster', 'DistributedPortGroup', 'DistributedSwitch', 'Folder', 'ResourcePool', 'VApp', 'VirtualPortGroup', 'VirtualMachine', 'VM', 'VMHost')]
    [string[]]$EntityType
)
Process {
    try {
        if ($EntityType -contains 'All') { $EntityType = @('All') }
        [string[]]$Properties = @('Name', 'Description', 'Cardinality', 'EntityType', 'Id')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Name = $Name }
        if ($PSBoundParameters.ContainsKey('Description')) { $cmdArgs.Add('Description', $Description) }
        if ($PSBoundParameters.ContainsKey('Cardinality')) { $cmdArgs.Add('Cardinality', $Cardinality) }
        if ($PSBoundParameters.ContainsKey('EntityType')) { $cmdArgs.Add('EntityType', $EntityType) }
        $result = New-TagCategory @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}