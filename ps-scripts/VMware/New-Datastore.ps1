#Requires -Version 5.1

<#
.SYNOPSIS
    VMware: Creates a new datastore
.DESCRIPTION
    Creates a new datastore on a vCenter Server system.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    Credentials for authenticating with the server
.PARAMETER Name
    Name of the new datastore
.PARAMETER Path
    Path for the new datastore
.PARAMETER VMHost
    Target host for the datastore
.EXAMPLE
    PS> ./New-Datastore.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "DS01" -Path "/vmfs/volumes/DS01" -VMHost "esxi01"
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
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$VMHost
)

Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $result = New-Datastore -Server $vmServer -Name $Name -Path $Path -VMHost $VMHost -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
