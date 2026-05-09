#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves tags
.DESCRIPTION
    Retrieves tags by name or category.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the tag
.PARAMETER Category
    Name of the tag category
.PARAMETER Properties
    List of properties to expand; use * for all
.EXAMPLE
    PS> ./Get-Tag.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$Name,
    [string]$Category,
    [ValidateSet('*', 'Name', 'Description', 'Category', 'Id', 'Uid')]
    [string[]]$Properties = @('Name', 'Description', 'Category', 'Id')
)
Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSBoundParameters.ContainsKey('Name')) { $cmdArgs.Add('Name', $Name) }
        if ($PSBoundParameters.ContainsKey('Category')) { $cat = Get-TagCategory @cmdArgs -Name $Category -ErrorAction Stop; $cmdArgs.Add('Category', $cat) }
        $result = Get-Tag @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}