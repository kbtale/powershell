#Requires -Version 5.1

<#
.SYNOPSIS
    VMware: Removes a datastore
.DESCRIPTION
    Removes a datastore from a vCenter Server system.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    Credentials for authenticating with the server
.PARAMETER Datastore
    Name of the datastore to remove
.EXAMPLE
    PS> ./Remove-Datastore.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Datastore "DS01"
.CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Datastore
)

Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        Remove-Datastore -Server $vmServer -Datastore $Datastore -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Datastore = $Datastore; Message = "Datastore '$Datastore' removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
