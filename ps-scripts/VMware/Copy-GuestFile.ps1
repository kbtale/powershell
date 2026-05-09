#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Copies files and folders from and to the guest OS
.DESCRIPTION
    Copies files between local system and virtual machine guest OS.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Name of the virtual machine
.PARAMETER Source
    Source file path (absolute for guest, relative supported for local)
.PARAMETER Destination
    Destination path (absolute for guest, relative supported for local)
.PARAMETER ToolsWaitSecs
    Time in seconds to wait for VMware Tools response
.PARAMETER HostCredential
    PSCredential for authenticating with the host
.PARAMETER GuestCredential
    PSCredential for authenticating with the guest OS
.PARAMETER HostUser
    User name for authenticating with the host
.PARAMETER GuestUser
    User name for authenticating with the guest OS
.PARAMETER HostPassword
    Password for authenticating with the host
.PARAMETER GuestPassword
    Password for authenticating with the guest OS
.EXAMPLE
    PS> ./Copy-GuestFile.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "MyVM" -Source "C:\local\file.txt" -Destination "/tmp/"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "LocalToGuest")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true, ParameterSetName = "GuestToLocal")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true, ParameterSetName = "GuestToLocal")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true, ParameterSetName = "GuestToLocal")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true, ParameterSetName = "GuestToLocal")]
    [string]$Source,
    [Parameter(Mandatory = $true, ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true, ParameterSetName = "GuestToLocal")]
    [string]$Destination,
    [int]$ToolsWaitSecs = 300,
    [pscredential]$HostCredential,
    [pscredential]$GuestCredential,
    [string]$HostUser,
    [string]$GuestUser,
    [securestring]$HostPassword,
    [securestring]$GuestPassword
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Source = $Source; Destination = $Destination; Confirm = $false; Force = $null; ToolsWaitSecs = $ToolsWaitSecs }
        if ($PSCmdlet.ParameterSetName -eq "LocalToGuest") { $cmdArgs.Add("LocalToGuest", $null) }
        else { $cmdArgs.Add("GuestToLocal", $null) }
        $vm = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        $cmdArgs.Add('VM', $vm)
        if ($PSBoundParameters.ContainsKey('HostCredential')) { $cmdArgs.Add('HostCredential', $HostCredential) }
        if ($PSBoundParameters.ContainsKey('HostPassword')) { $cmdArgs.Add('HostPassword', $HostPassword) }
        if ($PSBoundParameters.ContainsKey('HostUser')) { $cmdArgs.Add('HostUser', $HostUser) }
        if ($PSBoundParameters.ContainsKey('GuestCredential')) { $cmdArgs.Add('GuestCredential', $GuestCredential) }
        if ($PSBoundParameters.ContainsKey('GuestUser')) { $cmdArgs.Add('GuestUser', $GuestUser) }
        if ($PSBoundParameters.ContainsKey('GuestPassword')) { $cmdArgs.Add('GuestPassword', $GuestPassword) }
        $result = Copy-VMGuestFile @cmdArgs
        $output = [PSCustomObject]@{
            Timestamp = $timestamp
            Status    = "Success"
            Message   = "File copied from $Source to $Destination"
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
