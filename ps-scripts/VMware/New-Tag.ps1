#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new tag
.DESCRIPTION
    Creates a new tag in a specified category.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the new tag
.PARAMETER Category
    Category of the new tag
.PARAMETER Description
    Description of the new tag
.EXAMPLE
    PS> ./New-Tag.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "Production" -Category "Environment"
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
    [Parameter(Mandatory = $true)]
    [string]$Category,
    [string]$Description
)
Process {
    try {
        [string[]]$Properties = @('Name', 'Description', 'Category', 'Id')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Name = $Category }
        $cat = Get-TagCategory @cmdArgs -ErrorAction Stop
        $cmdArgs.Add('Category', $cat)
        $cmdArgs['Name'] = $Name
        if ($PSBoundParameters.ContainsKey('Description')) { $cmdArgs.Add('Description', $Description) }
        $result = New-Tag @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}