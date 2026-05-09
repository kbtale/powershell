#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves all available patches
.DESCRIPTION
    Retrieves patches from the Update Manager with filtering options.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER SearchPhrase
    Phrases in Name, Description, Id, or Vendor (comma-separated)
.PARAMETER Id
    ID of the patch
.PARAMETER After
    Only patches released after this date
.PARAMETER Before
    Only patches released before this date
.PARAMETER BundleType
    Bundle type: Patch, Rollup, Update, Extension, Upgrade
.PARAMETER Category
    Categories: SecurityFix, BugFix, Enhancement, Other
.PARAMETER InstallationImpact
    Installation impact filter
.PARAMETER Severity
    Severity: Critical, Important, Moderate, Low, etc.
.PARAMETER Product
    Name of the software product
.PARAMETER Vendor
    Vendor of the patch
.PARAMETER Properties
    List of properties to expand; use * for all
.EXAMPLE
    PS> ./Get-Patch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Severity "Critical"
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
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($Id -gt 0) { $cmdArgs.Add('Id', $Id) }
        if ($PSBoundParameters.ContainsKey('BundleType')) { $cmdArgs.Add('BundleType', $BundleType) }
        if ($PSBoundParameters.ContainsKey('Category')) { $cmdArgs.Add('Category', $Category) }
        if (($PSBoundParameters.ContainsKey('After')) -and ($After.Year -gt 2020)) { $cmdArgs.Add('After', $After) }
        if (($PSBoundParameters.ContainsKey('Before')) -and ($Before.Year -gt 2020)) { $cmdArgs.Add('Before', $Before) }
        if ($PSBoundParameters.ContainsKey('InstallationImpact')) { $cmdArgs.Add('InstallationImpact', $InstallationImpact) }
        if ($PSBoundParameters.ContainsKey('Product')) { $cmdArgs.Add('Product', $Product) }
        if ($PSBoundParameters.ContainsKey('SearchPhrase')) { $cmdArgs.Add('SearchPhrase', $SearchPhrase) }
        if ($PSBoundParameters.ContainsKey('Severity')) { $cmdArgs.Add('Severity', $Severity) }
        if ($PSBoundParameters.ContainsKey('Vendor')) { $cmdArgs.Add('Vendor', $Vendor) }
        $result = Get-Patch @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}