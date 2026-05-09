#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves folders available on a vCenter Server system
.DESCRIPTION
    Retrieves folders by name, location, or type.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER FolderName
    Name of the folder to retrieve; retrieves all if empty
.PARAMETER LocationName
    Container object where to retrieve the folder
.PARAMETER LocationType
    Type of the container object (All, VM, HostAndCluster, Datastore, Network, Datacenter)
.PARAMETER NoRecursion
    Disable the recursive behavior of the command
.EXAMPLE
    PS> ./Get-Folder.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$FolderName = '*',
    [string]$LocationName,
    [ValidateSet("All", "VM", "HostAndCluster", "Datastore", "Network", "Datacenter")]
    [string]$LocationType,
    [switch]$NoRecursion
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if (-not [System.String]::IsNullOrWhiteSpace($LocationName)) {
            $location = Get-Folder @cmdArgs -Name $LocationName -ErrorAction Stop
            if ($null -eq $location) { throw "Location $LocationName not found" }
            $cmdArgs.Add('Location', $location)
        }
        $cmdArgs.Add('Name', $FolderName)
        if ($NoRecursion) { $cmdArgs.Add('NoRecursion', $true) }
        if (-not [System.String]::IsNullOrWhiteSpace($LocationType) -and $LocationType -ne 'All') { $cmdArgs.Add('Type', $LocationType) }
        $result = Get-Folder @cmdArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}