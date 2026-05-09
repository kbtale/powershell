#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Copies an OS customization specification
.DESCRIPTION
    Copies an existing OS customization specification to create a new one.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER SourceSpecificationId
    ID of the source OS customization specification
.PARAMETER SpecName
    Name of the new OS customization specification
.PARAMETER SpecificationType
    Type: Persistent or NonPersistent
.EXAMPLE
    PS> ./Copy-OSCustomizationSpec.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -SourceSpecificationId "spec-123" -SpecName "CopiedSpec"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$SourceSpecificationId,
    [Parameter(Mandatory = $true)]
    [string]$SpecName,
    [ValidateSet("Persistent", "NonPersistent")]
    [string]$SpecificationType
)
Process {
    try {
        [string[]]$Properties = @('Name', 'Type', 'Server', 'LastUpdate', 'DomainAdminUsername', 'DomainUsername', 'Description', 'Domain', 'FullName', 'OSType', 'LicenseMode', 'LicenseMaxConnections', 'Id')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer }
        $spec = Get-OSCustomizationSpec @cmdArgs -ID $SourceSpecificationId -ErrorAction Stop
        $cmdArgs.Add('Confirm', $false)
        $cmdArgs.Add('Name', $SpecName)
        $cmdArgs.Add('OSCustomizationSpec', $spec)
        if ($PSBoundParameters.ContainsKey('SpecificationType')) { $cmdArgs.Add('Type', $SpecificationType) }
        $result = New-OSCustomizationSpec @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}