#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new folder on a vCenter Server system
.DESCRIPTION
    Creates a new folder in a specified location.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER FolderName
    Name for the new folder
.PARAMETER LocationName
    Container object where to place the new folder
.PARAMETER LocationType
    Type of the container object (VM, HostAndCluster, Datacenter)
.EXAMPLE
    PS> ./New-Folder.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -FolderName "NewFolder" -LocationName "Datacenter01" -LocationType "Datacenter"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [Parameter(Mandatory = $true)]
    [string]$LocationName,
    [Parameter(Mandatory = $true)]
    [ValidateSet("VM", "HostAndCluster", "Datacenter")]
    [string]$LocationType = "VM"
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $location = Get-Folder -Server $vmServer -Name $LocationName -Type $LocationType -ErrorAction Stop
        if ($null -eq $location) { throw "Location $LocationName not found" }
        $result = New-Folder -Server $vmServer -Name $FolderName -Location $location -Confirm:$false -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}