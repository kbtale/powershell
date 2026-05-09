#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Imports a host profile from a file
.DESCRIPTION
    Imports a host profile from a file with optional description.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ProfileName
    Name of the imported host profile
.PARAMETER FilePath
    Path to the file from which to import the host profile
.PARAMETER Description
    Description for the imported host profile
.EXAMPLE
    PS> ./Import-HostProfile.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -ProfileName "NewProfile" -FilePath "C:\import\profile.vpf"
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
    [string]$FilePath,
    [string]$Description
)
Process {
    $vmServer = $null
    try {
        if ([System.String]::IsNullOrWhiteSpace($Description)) { $Description = " " }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $null = Import-VMHostProfile -FilePath $FilePath -Name $ProfileName -Server $vmServer -Description $Description -Confirm:$false -ErrorAction Stop
        $result = Get-VMHostProfile -Server $vmServer -Name $ProfileName -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
