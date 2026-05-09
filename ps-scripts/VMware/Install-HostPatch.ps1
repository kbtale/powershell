#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Updates the specified host with patches
.DESCRIPTION
    Installs patches on a host from a web, host, or local path.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host to update
.PARAMETER HostPath
    File path on the ESX/ESXi host to the patches
.PARAMETER WebPath
    Web location of the patches
.PARAMETER LocalPath
    Local file system path to the patches
.PARAMETER HostCredential
    PSCredential object for authenticating with the host
.PARAMETER HostUsername
    User name for authenticating with the host
.PARAMETER HostPassword
    Password for authenticating with the host
.PARAMETER RunAsync
    Return immediately without waiting for completion
.EXAMPLE
    PS> ./Install-HostPatch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -WebPath "http://update/patch.zip"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "HostPath")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "HostPath")]
    [Parameter(Mandatory = $true, ParameterSetName = "WebPath")]
    [Parameter(Mandatory = $true, ParameterSetName = "LocalPath")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "HostPath")]
    [Parameter(Mandatory = $true, ParameterSetName = "WebPath")]
    [Parameter(Mandatory = $true, ParameterSetName = "LocalPath")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "HostPath")]
    [Parameter(Mandatory = $true, ParameterSetName = "WebPath")]
    [Parameter(Mandatory = $true, ParameterSetName = "LocalPath")]
    [string]$HostName,
    [Parameter(Mandatory = $true, ParameterSetName = "HostPath")]
    [string]$HostPath,
    [Parameter(Mandatory = $true, ParameterSetName = "WebPath")]
    [string]$WebPath,
    [Parameter(Mandatory = $true, ParameterSetName = "LocalPath")]
    [string]$LocalPath,
    [Parameter(ParameterSetName = "LocalPath")]
    [pscredential]$HostCredential,
    [Parameter(ParameterSetName = "LocalPath")]
    [string]$HostUsername,
    [Parameter(ParameterSetName = "LocalPath")]
    [securestring]$HostPassword,
    [Parameter(ParameterSetName = "HostPath")]
    [Parameter(ParameterSetName = "WebPath")]
    [Parameter(ParameterSetName = "LocalPath")]
    [switch]$RunAsync
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; RunAsync = $RunAsync; Confirm = $false }
        $vmHost = Get-VMHost @cmdArgs -Name $HostName
        $cmdArgs.Add('VMHost', $vmHost)
        if ($PSCmdlet.ParameterSetName -eq 'LocalPath') {
            if ($PSBoundParameters.ContainsKey('HostCredential')) { $cmdArgs.Add('HostCredential', $HostCredential) }
            else {
                if ($PSBoundParameters.ContainsKey('HostUsername')) { $cmdArgs.Add('HostUsername', $HostUsername) }
                if ($PSBoundParameters.ContainsKey('HostPassword')) { $cmdArgs.Add('HostPassword', $HostPassword) }
            }
            $result = Install-VMHostPatch @cmdArgs -LocalPath $LocalPath
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'WebPath') {
            $result = Install-VMHostPatch @cmdArgs -WebPath $WebPath
        }
        else {
            $result = Install-VMHostPatch @cmdArgs -HostPath $HostPath
        }
        if ($null -ne $result) {
            $result | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $result
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
