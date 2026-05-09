#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Initializes staging of patches
.DESCRIPTION
    Stages patches to a specified VMHost, Cluster, or Datacenter entity.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Entity
    VMHost, Cluster, or Datacenter for which to stage patches
.EXAMPLE
    PS> ./Copy-Patch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Entity "MyCluster"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Entity
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $result = Copy-Patch -Server $vmServer -Entity $Entity -Confirm:$false -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}