#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Exports the specified host profile to a file
.DESCRIPTION
    Exports a host profile to a specified file path.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name of the host profile to export
.PARAMETER FilePath
    Path to the file where to export the host profile
.EXAMPLE
    PS> ./Export-HostProfile.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "MyProfile" -FilePath "C:\export\profile.vpf"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $hProfile = Get-VMHostProfile -Name $Name -Server $vmServer -ErrorAction Stop
        Export-VMHostProfile -FilePath $FilePath -Profile $hProfile -Force:$true -Server $vmServer -ErrorAction Stop
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Host profile $Name successfully exported to $FilePath"
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
