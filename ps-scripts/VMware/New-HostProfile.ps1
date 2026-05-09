#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new host profile based on a reference host
.DESCRIPTION
    Creates a new host profile from a reference host.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ProfileName
    Name for the new host profile
.PARAMETER HostName
    Name of the reference host
.PARAMETER CompatibilityMode
    Make profile compatible with ESX/vCenter Server versions earlier than 5.0
.PARAMETER Description
    Description for the new host profile
.EXAMPLE
    PS> ./New-HostProfile.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -ProfileName "MyProfile" -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$ProfileName,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [switch]$CompatibilityMode,
    [string]$Description
)
Process {
    $vmServer = $null
    try {
        if ([System.String]::IsNullOrWhiteSpace($Description)) { $Description = " " }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $null = New-VMHostProfile -Server $vmServer -Name $ProfileName -ReferenceHost $vmHost -CompatibilityMode:$CompatibilityMode -Description $Description -ErrorAction Stop
        $result = Get-VMHostProfile -Server $vmServer -Name $ProfileName -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
