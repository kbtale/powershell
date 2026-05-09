#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies an OS customization specification
.DESCRIPTION
    Modifies settings of an OS customization specification by name or ID.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the OS customization specification
.PARAMETER SpecName
    Name of the OS customization specification
.PARAMETER Description
    New description
.PARAMETER DeleteAccounts
    Delete all user accounts
.PARAMETER AutoLogonCount
    Number of times to auto-login
.PARAMETER DNSServer
    DNS server
.PARAMETER AdminFullName
    Administrator full name
.PARAMETER AdminPassword
    Administrator password
.PARAMETER NewName
    New name for the specification
.PARAMETER OrgName
    Organization name
.PARAMETER NamingScheme
    Naming scheme: Custom, Fixed, Prefix, VM
.PARAMETER ProductKey
    MS product key
.PARAMETER SpecificationType
    Type: Persistent or NonPersistent
.PARAMETER Domain
    Domain name
.PARAMETER DomainCredentials
    Credential for domain authentication
.PARAMETER DomainUsername
    Username for domain authentication
.PARAMETER DomainPassword
    Password for domain authentication
.PARAMETER TimeZone
    Time zone for Windows guest OS
.PARAMETER Workgroup
    Workgroup name
.EXAMPLE
    PS> ./Set-OSCustomizationSpec.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -SpecName "Win10Spec" -NewName "Win11Spec"
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
    [string]$Description,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [bool]$DeleteAccounts,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [int]$AutoLogonCount,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$DNSServer,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$AdminFullName,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$AdminPassword,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$NewName,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$OrgName,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [ValidateSet("Custom", "Fixed", "Prefix", "Vm")]
    [string]$NamingScheme,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$ProductKey,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [ValidateSet("Persistent", "NonPersistent")]
    [string]$SpecificationType,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$Domain,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [pscredential]$DomainCredentials,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$DomainUsername,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$DomainPassword,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [ValidateSet('W. Europe', 'E. Europe', 'Central Europe', 'Central European', 'Central (U.S. and Canada)', 'Central America', 'Eastern (U.S. and Canada)', 'GMT (Greenwich Mean Time)', 'GMT Greenwich', 'EET (Athens, Istanbul, Minsk)', 'EET (Helsinki, Riga, Tallinn)')]
    [string]$TimeZone,
    [Parameter(ParameterSetName = "ByName")]
    [Parameter(ParameterSetName = "ById")]
    [string]$Workgroup
)
Process {
    try {
        [string[]]$Properties = @('Name', 'Type', 'Server', 'LastUpdate', 'DomainAdminUsername', 'DomainUsername', 'Description', 'Domain', 'FullName', 'OSType', 'LicenseMode', 'LicenseMaxConnections', 'Id')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        if ($PSCmdlet.ParameterSetName -eq "ById") { $cmdArgs.Add('Id', $ID) }
        else { $cmdArgs.Add('Name', $SpecName) }
        $spec = Get-OSCustomizationSpec @cmdArgs -ErrorAction Stop
        $setArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; OSCustomizationSpec = $spec; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('AutoLogonCount')) { $setArgs.Add('AutoLogonCount', $AutoLogonCount) }
        if ($PSBoundParameters.ContainsKey('AdminPassword')) { $setArgs.Add('AdminPassword', $AdminPassword) }
        if ($PSBoundParameters.ContainsKey('DeleteAccounts')) { $setArgs.Add('DeleteAccounts', $DeleteAccounts) }
        if ($PSBoundParameters.ContainsKey('Description')) { $setArgs.Add('Description', $Description) }
        if ($PSBoundParameters.ContainsKey('DNSServer')) { $setArgs.Add('DNSServer', $DNSServer) }
        if ($PSBoundParameters.ContainsKey('Domain')) { $setArgs.Add('Domain', $Domain) }
        if ($PSBoundParameters.ContainsKey('DomainUsername')) { $setArgs.Add('DomainUsername', $DomainUsername) }
        if ($PSBoundParameters.ContainsKey('DomainPassword')) { $setArgs.Add('DomainPassword', $DomainPassword) }
        if ($PSBoundParameters.ContainsKey('DomainCredentials')) { $setArgs.Add('DomainCredentials', $DomainCredentials) }
        if ($PSBoundParameters.ContainsKey('AdminFullName')) { $setArgs.Add('FullName', $AdminFullName) }
        if ($PSBoundParameters.ContainsKey('NewName')) { $setArgs.Add('Name', $NewName) }
        if ($PSBoundParameters.ContainsKey('NamingScheme')) { $setArgs.Add('NamingScheme', $NamingScheme) }
        if ($PSBoundParameters.ContainsKey('OrgName')) { $setArgs.Add('OrgName', $OrgName) }
        if ($PSBoundParameters.ContainsKey('ProductKey')) { $setArgs.Add('ProductKey', $ProductKey) }
        if ($PSBoundParameters.ContainsKey('TimeZone')) { $setArgs.Add('TimeZone', $TimeZone) }
        if ($PSBoundParameters.ContainsKey('SpecificationType')) { $setArgs.Add('Type', $SpecificationType) }
        if ($PSBoundParameters.ContainsKey('Workgroup')) { $setArgs.Add('Workgroup', $Workgroup) }
        $result = Set-OSCustomizationSpec @setArgs -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}