#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Configures a host account
.DESCRIPTION
    Modifies password, description, and shell access of a host user account.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Id
    ID of the host user account to configure
.PARAMETER Password
    New password for the host user account
.PARAMETER Description
    Description of the specified account
.PARAMETER GrantShellAccess
    Account is allowed to access the ESX shell
.EXAMPLE
    PS> ./Set-HostAccount.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Id "root" -Description "Admin account"
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
    [string]$Password,
    [string]$Description,
    [bool]$GrantShellAccess
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $uAccount = Get-VMHostAccount -Server $vmServer -Id $Id -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; UserAccount = $uAccount; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('Password')) { $uAccount = Set-VMHostAccount @cmdArgs -Password $Password }
        if ($PSBoundParameters.ContainsKey('Description')) { $uAccount = Set-VMHostAccount @cmdArgs -Description $Description }
        if ($PSBoundParameters.ContainsKey('GrantShellAccess')) { $uAccount = Set-VMHostAccount @cmdArgs -GrantShellAccess $GrantShellAccess }
        $result = $uAccount | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
