#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new OS customization specification
.DESCRIPTION
    Creates a new OS customization specification with Windows sysprep settings.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER SpecName
    Name for the new customization specification
.PARAMETER AdminFullName
    Administrator full name
.PARAMETER OrgName
    Organization name
.PARAMETER Description
    Description of the specification
.PARAMETER DeleteAccounts
    Delete all user accounts
.PARAMETER AutoLogonCount
    Number of times to auto-login as administrator
.PARAMETER DNSServer
    DNS server address
.PARAMETER AdminPassword
    Administrator password
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
    PS> ./New-OSCustomizationSpec.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -SpecName "Win10Spec" -AdminFullName "Admin" -OrgName "Contoso"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$SpecName,
    [Parameter(Mandatory = $true)]
    [string]$AdminFullName,
    [Parameter(Mandatory = $true)]
    [string]$OrgName,
    [string]$Description,
    [bool]$DeleteAccounts,
    [int]$AutoLogonCount,
    [string]$DNSServer,
    [string]$AdminPassword,
    [ValidateSet("Custom", "Fixed", "Prefix", "Vm")]
    [string]$NamingScheme,
    [string]$ProductKey,
    [ValidateSet("Persistent", "NonPersistent")]
    [string]$SpecificationType,
    [string]$Domain,
    [pscredential]$DomainCredentials,
    [string]$DomainUsername,
    [string]$DomainPassword,
    [ValidateSet('W. Europe', 'E. Europe', 'Central Europe', 'Central European', 'Central (U.S. and Canada)', 'Central America', 'Eastern (U.S. and Canada)', 'GMT (Greenwich Mean Time)', 'GMT Greenwich', 'EET (Athens, Istanbul, Minsk)', 'EET (Helsinki, Riga, Tallinn)')]
    [string]$TimeZone,
    [string]$Workgroup
)
Process {
    try {
        [string[]]$Properties = @('Name', 'Type', 'Server', 'LastUpdate', 'DomainAdminUsername', 'DomainUsername', 'Description', 'Domain', 'FullName', 'OSType', 'LicenseMode', 'LicenseMaxConnections', 'Id')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Confirm = $false; FullName = $AdminFullName; OrgName = $OrgName }
        if ($PSBoundParameters.ContainsKey('SpecName')) { $cmdArgs.Add('Name', $SpecName) }
        if ($PSBoundParameters.ContainsKey('AutoLogonCount')) { $cmdArgs.Add('AutoLogonCount', $AutoLogonCount) }
        if ($PSBoundParameters.ContainsKey('AdminPassword')) { $cmdArgs.Add('AdminPassword', $AdminPassword) }
        if ($PSBoundParameters.ContainsKey('DeleteAccounts')) { $cmdArgs.Add('DeleteAccounts', $DeleteAccounts) }
        if ($PSBoundParameters.ContainsKey('Description')) { $cmdArgs.Add('Description', $Description) }
        if ($PSBoundParameters.ContainsKey('DNSServer')) { $cmdArgs.Add('DNSServer', $DNSServer) }
        if ($PSBoundParameters.ContainsKey('Domain')) { $cmdArgs.Add('Domain', $Domain) }
        if ($PSBoundParameters.ContainsKey('DomainUsername')) { $cmdArgs.Add('DomainUsername', $DomainUsername) }
        if ($PSBoundParameters.ContainsKey('DomainPassword')) { $cmdArgs.Add('DomainPassword', $DomainPassword) }
        if ($PSBoundParameters.ContainsKey('DomainCredentials')) { $cmdArgs.Add('DomainCredentials', $DomainCredentials) }
        if ($PSBoundParameters.ContainsKey('NamingScheme')) { $cmdArgs.Add('NamingScheme', $NamingScheme) }
        if ($PSBoundParameters.ContainsKey('ProductKey')) { $cmdArgs.Add('ProductKey', $ProductKey) }
        if ($PSBoundParameters.ContainsKey('TimeZone')) { $cmdArgs.Add('TimeZone', $TimeZone) }
        if ($PSBoundParameters.ContainsKey('SpecificationType')) { $cmdArgs.Add('Type', $SpecificationType) }
        if ($PSBoundParameters.ContainsKey('Workgroup')) { $cmdArgs.Add('Workgroup', $Workgroup) }
        $result = New-OSCustomizationSpec @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}