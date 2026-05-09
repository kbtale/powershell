#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new host user account
.DESCRIPTION
    Creates a new host user account with optional description and shell access.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Id
    ID for the new host account
.PARAMETER Password
    Password for the new host account
.PARAMETER Description
    Description of the new host account
.PARAMETER GrantShellAccess
    Allow access to the ESX shell
.EXAMPLE
    PS> ./New-HostAccount.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Id "admin" -Password $securePass
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [Parameter(Mandatory = $true)]
    [securestring]$Password,
    [string]$Description,
    [switch]$GrantShellAccess
)
Process {
    $vmServer = $null
    try {
        if ([System.String]::IsNullOrWhiteSpace($Description)) { $Description = " " }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $result = New-VMHostAccount -Server $vmServer -Id $Id -Password $Password -Description $Description -GrantShellAccess:$GrantShellAccess -Confirm:$false -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
