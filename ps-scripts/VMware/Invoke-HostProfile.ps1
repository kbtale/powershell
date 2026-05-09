#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Applies a host profile to the specified host or cluster
.DESCRIPTION
    Applies a host profile to a host or cluster, with options to apply only or associate only.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ProfileName
    Host profile to apply
.PARAMETER HostName
    Host to apply the host profile to
.PARAMETER ClusterName
    Cluster to apply the host profile to
.PARAMETER ApplyOnly
    Apply the host profile without associating it
.PARAMETER AssociateOnly
    Associate the host profile without applying it
.EXAMPLE
    PS> ./Invoke-HostProfile.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -ProfileName "MyProfile" -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "Host")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Host")]
    [Parameter(Mandatory = $true, ParameterSetName = "Cluster")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "Host")]
    [Parameter(Mandatory = $true, ParameterSetName = "Cluster")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "Host")]
    [Parameter(Mandatory = $true, ParameterSetName = "Cluster")]
    [string]$ProfileName,
    [Parameter(Mandatory = $true, ParameterSetName = "Host")]
    [string]$HostName,
    [Parameter(Mandatory = $true, ParameterSetName = "Cluster")]
    [string]$ClusterName,
    [Parameter(ParameterSetName = "Host")]
    [Parameter(ParameterSetName = "Cluster")]
    [switch]$ApplyOnly,
    [Parameter(ParameterSetName = "Host")]
    [Parameter(ParameterSetName = "Cluster")]
    [switch]$AssociateOnly
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $profile = Get-VMHostProfile -Name $ProfileName -Server $vmServer -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "Host") {
            $entity = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        }
        else {
            $entity = Get-Cluster -Server $vmServer -Name $ClusterName -ErrorAction Stop
        }
        $null = Invoke-VMHostProfile -Entity $entity -Profile $profile -AssociateOnly:$AssociateOnly -ApplyOnly:$ApplyOnly -Server $vmServer -Confirm:$false -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "Host") {
            $result = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-Cluster -Server $vmServer -Name $ClusterName -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
