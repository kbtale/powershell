#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes the specified folder
.DESCRIPTION
    Removes a folder from a vCenter Server.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER FolderName
    Name of the folder to remove
.PARAMETER DeletePermanently
    Delete from disk any VMs contained in the folder
.EXAMPLE
    PS> ./Remove-Folder.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -FolderName "OldFolder"
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
    [switch]$DeletePermanently
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $folder = Get-Folder -Server $vmServer -Name $FolderName -ErrorAction Stop
        if ($null -eq $folder) { throw "Folder $FolderName not found" }
        Remove-Folder -Server $vmServer -Folder $folder -DeletePermanently:$DeletePermanently -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Folder $FolderName successfully removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}