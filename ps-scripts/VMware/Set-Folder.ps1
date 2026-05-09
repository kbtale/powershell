#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the properties of a folder
.DESCRIPTION
    Renames a specified folder on a vCenter Server.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER FolderName
    Folder whose properties to change
.PARAMETER NewName
    New name for the folder
.EXAMPLE
    PS> ./Set-Folder.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -FolderName "OldFolder" -NewName "NewFolder"
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
    [string]$NewName
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $folder = Get-Folder -Server $vmServer -Name $FolderName -ErrorAction Stop
        if ($null -eq $folder) { throw "Folder $FolderName not found" }
        $result = Set-Folder -Server $vmServer -Folder $folder -Name $NewName -Confirm:$false -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}