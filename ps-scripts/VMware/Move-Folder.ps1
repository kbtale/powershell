#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Moves a vCenter Server folder from one location to another
.DESCRIPTION
    Moves a folder to a destination folder or datacenter.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER FolderName
    Name of the folder to move
.PARAMETER DestinationName
    Datacenter or folder where to move the folder
.EXAMPLE
    PS> ./Move-Folder.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -FolderName "ProjectX" -DestinationName "Archived"
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
    [string]$DestinationName
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $folder = Get-Folder -Server $vmServer -Name $FolderName -ErrorAction Stop
        if ($null -eq $folder) { throw "Folder $FolderName not found" }
        $destination = Get-Folder -Server $vmServer -Name $DestinationName -ErrorAction Stop
        if ($null -eq $destination) { throw "Destination $DestinationName not found" }
        $result = Move-Folder -Server $vmServer -Folder $folder -Destination $destination -Confirm:$false -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}