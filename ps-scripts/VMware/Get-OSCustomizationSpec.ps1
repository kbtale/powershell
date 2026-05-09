#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves OS customization specifications
.DESCRIPTION
    Retrieves OS customization specifications by name, ID, or type.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the OS customization specification
.PARAMETER SpecName
    Name of the OS customization specification
.PARAMETER SpecificationType
    Type: Persistent or NonPersistent
.PARAMETER Properties
    List of properties to expand; use * for all
.EXAMPLE
    PS> ./Get-OSCustomizationSpec.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "ByName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]
    [Parameter(Mandatory = $true, ParameterSetName = "ById")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]
    [Parameter(Mandatory = $true, ParameterSetName = "ById")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "ById")]
    [string]$ID,
    [Parameter(ParameterSetName = "ByName")]
    [string]$SpecName,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [ValidateSet("Persistent", "NonPersistent")]
    [string]$SpecificationType,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [ValidateSet('*', 'Name', 'Type', 'Server', 'LastUpdate', 'DomainAdminUsername', 'DomainUsername', 'Description', 'AutoLogonCount', 'ChangeSid', 'DeleteAccounts', 'DnsServer', 'DnsSuffix', 'Domain', 'FullName', 'NamingScheme', 'OrgName', 'OSType', 'ProductKey', 'TimeZone', 'Workgroup', 'LicenseMode', 'LicenseMaxConnections', 'Id', 'Uid')]
    [string[]]$Properties = @('Name', 'Type', 'Server', 'LastUpdate', 'DomainAdminUsername', 'DomainUsername', 'Description', 'Domain', 'FullName', 'OSType', 'LicenseMode', 'LicenseMaxConnections', 'Id')
)
Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSCmdlet.ParameterSetName -eq "ById") { $cmdArgs.Add('Id', $ID) }
        elseif ($PSBoundParameters.ContainsKey('SpecName')) { $cmdArgs.Add('Name', $SpecName) }
        if ($PSBoundParameters.ContainsKey('SpecificationType')) { $cmdArgs.Add('Type', $SpecificationType) }
        $result = Get-OSCustomizationSpec @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}