#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the specified host profile
.DESCRIPTION
    Modifies the name or description of a host profile.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ProfileName
    Name of the host profile to modify
.PARAMETER Description
    New description for the host profile
.PARAMETER NewName
    New name for the host profile
.EXAMPLE
    PS> ./Set-HostProfile.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -ProfileName "MyProfile" -Description "Updated description"
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
    [string]$Description,
    [string]$NewName
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $profile = Get-VMHostProfile -Server $vmServer -Name $ProfileName -ErrorAction Stop
        if (-not [System.String]::IsNullOrWhiteSpace($Description)) {
            $null = Set-VMHostProfile -Profile $profile -Server $vmServer -Description $Description -Confirm:$false -ErrorAction Stop
        }
        if (-not [System.String]::IsNullOrWhiteSpace($NewName)) {
            $null = Set-VMHostProfile -Profile $profile -Server $vmServer -Name $NewName -Confirm:$false -ErrorAction Stop
        }
        $result = Get-VMHostProfile -Server $vmServer -Name $ProfileName -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
