#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes the specified host profile
.DESCRIPTION
    Removes a host profile by name from the vCenter Server system.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ProfileName
    Name of the host profile to remove
.EXAMPLE
    PS> ./Remove-HostProfile.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -ProfileName "MyProfile"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$ProfileName
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $profile = Get-VMHostProfile -Server $vmServer -Name $ProfileName -ErrorAction Stop
        $null = Remove-VMHostProfile -Profile $profile -Server $vmServer -Confirm:$false -ErrorAction Stop
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Host profile $ProfileName successfully removed"
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
