#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies a tag
.DESCRIPTION
    Renames or changes the description of a tag.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the tag to modify
.PARAMETER NewName
    New name for the tag
.PARAMETER Description
    New description for the tag
.EXAMPLE
    PS> ./Set-Tag.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "OldTag" -NewName "NewTag"
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
    [string]$Description
)
Process {
    try {
        [string[]]$Properties = @('Name', 'Description', 'Category', 'Id')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        $tag = Get-Tag @cmdArgs -Name $Name -ErrorAction Stop
        $cmdArgs.Add('Tag', $tag)
        if ($PSBoundParameters.ContainsKey('NewName')) { $cmdArgs.Add('Name', $NewName) }
        if ($PSBoundParameters.ContainsKey('Description')) { $cmdArgs.Add('Description', $Description) }
        $result = Set-Tag @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}