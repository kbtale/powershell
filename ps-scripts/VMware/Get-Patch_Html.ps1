#Requires -Version 5.1
#Requires -Modules VMware.VumAutomation
<#
.SYNOPSIS
    VMware: Creates a report with all available patches
.DESCRIPTION
    Generates an HTML fragment report of all available patches from VMware Update Manager.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Id
    ID of the patch to filter by
.PARAMETER After
    Only patches released after this date
.PARAMETER Before
    Only patches released before this date
.PARAMETER BundleType
    Bundle type of the patches
.PARAMETER Category
    Category of the patches
.PARAMETER InstallationImpact
    Installation impact of the patches
.PARAMETER Product
    Name of the software product
.PARAMETER SearchPhrase
    Phrases to search in Name, Description, Id, and Vendor
.PARAMETER Severity
    Severity of the patch
.PARAMETER Vendor
    Vendor of the patch
.PARAMETER Properties
    List of properties to expand; use * for all properties
.EXAMPLE
    PS> ./Get-Patch_Html.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [int]$Id,
    [datetime]$After,
    [datetime]$Before,
    [ValidateSet('Patch', 'Rollup', 'Update', 'Extension', 'Upgrade')]
    [string]$BundleType,
    [ValidateSet('SecurityFix', 'BugFix', 'Enhancement', 'Other')]
    [string]$Category,
    [ValidateSet('HostdRestart', 'Reboot', 'MaintenanceMode', 'MaintenanceModeHostdRestart', 'MaintenanceModeInstall', 'MaintenanceModeUpdate', 'FaultToleranceCompatibiliy')]
    [string]$InstallationImpact,
    [string]$Product,
    [string]$SearchPhrase,
    [ValidateSet('NotApplicable', 'Low', 'Moderate', 'Important', 'Critical', 'HostGeneral', 'HostSecurity')]
    [string]$Severity,
    [string]$Vendor,
    [ValidateSet('*', 'Name', 'Id', 'Vendor', 'Language', 'Description', 'Product', 'ReleaseDate', 'LastUpdateTime', 'Severity', 'Category', 'TargetType', 'BundleType', 'IsRecalled', 'Uid')]
    [string[]]$Properties = @('Name', 'Id', 'Vendor', 'Language', 'Description', 'Product', 'ReleaseDate', 'LastUpdateTime')
)
Process {
    $vmServer = $null
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($Id -gt 0) { $cmdArgs.Add('Id', $Id) }
        if (($PSBoundParameters.ContainsKey('After')) -and ($After.Year -gt 2020)) { $cmdArgs.Add('After', $After) }
        if (($PSBoundParameters.ContainsKey('Before')) -and ($Before.Year -gt 2020)) { $cmdArgs.Add('Before', $Before) }
        if ($PSBoundParameters.ContainsKey('BundleType')) { $cmdArgs.Add('BundleType', $BundleType) }
        if ($PSBoundParameters.ContainsKey('Category')) { $cmdArgs.Add('Category', $Category) }
        if ($PSBoundParameters.ContainsKey('InstallationImpact')) { $cmdArgs.Add('InstallationImpact', $InstallationImpact) }
        if ($PSBoundParameters.ContainsKey('Product')) { $cmdArgs.Add('Product', $Product) }
        if ($PSBoundParameters.ContainsKey('SearchPhrase')) { $cmdArgs.Add('SearchPhrase', $SearchPhrase) }
        if ($PSBoundParameters.ContainsKey('Severity')) { $cmdArgs.Add('Severity', $Severity) }
        if ($PSBoundParameters.ContainsKey('Vendor')) { $cmdArgs.Add('Vendor', $Vendor) }
        $result = Get-Patch @cmdArgs | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
        }
        $html = $result | ConvertTo-Html -Fragment
        Write-Output $html
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
